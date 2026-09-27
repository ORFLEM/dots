#version 300 es

precision highp float;

in vec2 target_pixel_coordinates;
flat in vec4 source_uv_value;
flat in int texture_transform_value;

uniform sampler2D zwwm_window_texture;
uniform sampler2D zwwm_blurred_backdrop_texture;
uniform vec2 zwwm_output_size;
uniform vec4 zwwm_toplevel_rect;
uniform vec4 zwwm_texture_rect;
uniform vec4 zwwm_clip_rect;
uniform vec4 zwwm_color;
uniform float zwwm_opacity;
uniform float zwwm_clip_radius;
uniform int zwwm_state;
uniform bool zwwm_has_texture;

out vec4 fragment_color;

uniform int zwwm_config_radius;
uniform int zwwm_config_rounding_power;
uniform int zwwm_config_glass_width;
uniform int zwwm_config_glass_height;
uniform int zwwm_config_glass_radius;
uniform int zwwm_config_distortion_depth_per_mille;
uniform int zwwm_config_distortion_strength_per_mille;
uniform int zwwm_config_chromatic_shift;
uniform int zwwm_config_glass_tint_per_mille;

float power_length(vec2 value, float power) {
  return pow(pow(value.x, power) + pow(value.y, power), 1.0 / power);
}

float sdf(vec2 point, vec2 bounds, float radius, float power) {
  vec2 distance = abs(point) - bounds + vec2(radius);
  return min(max(distance.x, distance.y), 0.0) +
      power_length(max(distance, vec2(0.0)), power) - radius;
}

vec2 safe_normalize(vec2 value) {
  float scale = max(max(abs(value.x), abs(value.y)), 0.0001);
  vec2 scaled = value / scale;
  return scaled / max(length(scaled), 0.0001);
}

float rounded_rect_coverage(vec2 point, vec2 size, float radius, float power) {
  float clamped_radius = clamp(radius, 0.0, 0.5 * min(size.x, size.y));
  vec2 distance = abs(point - size * 0.5) - size * 0.5 + vec2(clamped_radius);
  float signed_distance = power_length(max(distance, vec2(0.0)), power) +
      min(max(distance.x, distance.y), 0.0) - clamped_radius;
  return clamp(0.5 - signed_distance, 0.0, 1.0);
}

vec2 backdrop_uv(vec2 output_position) {
  return clamp(vec2(output_position.x,
                    zwwm_output_size.y - output_position.y) /
                   max(zwwm_output_size, vec2(1.0)),
               vec2(0.0), vec2(1.0));
}

vec3 backdrop_color(vec2 output_position) {
  return texture(zwwm_blurred_backdrop_texture, backdrop_uv(output_position)).rgb;
}

vec2 client_uv(vec2 output_position) {
  vec2 position = clamp((output_position - zwwm_texture_rect.xy) /
                        max(zwwm_texture_rect.zw, vec2(1.0)),
                        vec2(0.0), vec2(1.0));
  if (texture_transform_value == 1)
    position = vec2(position.y, 1.0 - position.x);
  else if (texture_transform_value == 2)
    position = vec2(1.0) - position;
  else if (texture_transform_value == 3)
    position = vec2(1.0 - position.y, position.x);
  return mix(source_uv_value.xy, source_uv_value.zw, position);
}

void main() {
  vec4 client = vec4(zwwm_color.rgb * zwwm_color.a, zwwm_color.a);
  if (zwwm_has_texture)
    client *= texture(zwwm_window_texture, client_uv(target_pixel_coordinates));
  if ((zwwm_state & 4) != 0) {
    fragment_color = client * zwwm_opacity;
    return;
  }

  vec2 rect_size = zwwm_toplevel_rect.zw;
  vec2 fragment_position = target_pixel_coordinates - zwwm_toplevel_rect.xy;
  float glass_width_px = float(zwwm_config_glass_width);
  float glass_height_px = float(zwwm_config_glass_height);
  float geometry_scale = zwwm_config_radius > 0
      ? zwwm_clip_radius / float(zwwm_config_radius) : 1.0;
  float glass_radius_px = float(zwwm_config_glass_radius) * geometry_scale;
  float distortion_depth = float(zwwm_config_distortion_depth_per_mille) / 1000.0;
  float distortion_strength = float(zwwm_config_distortion_strength_per_mille) / 1000.0;
  float chromatic_shift_px = float(zwwm_config_chromatic_shift);
  float glass_tint = float(zwwm_config_glass_tint_per_mille) / 1000.0;
  float rounding_power = clamp(float(zwwm_config_rounding_power), 1.0, 16.0);
  vec2 glass_size = vec2(glass_width_px > 0.0 ? glass_width_px : rect_size.x,
                         glass_height_px > 0.0 ? glass_height_px : rect_size.y);
  vec2 glass_coordinate = fragment_position - rect_size * 0.5;
  float size = max(min(glass_size.x, glass_size.y), 1.0);
  float sdf_scale = max(max(glass_size.x, glass_size.y), 1.0);
  float inverse_sdf = -sdf(glass_coordinate / sdf_scale,
                            glass_size * 0.5 / sdf_scale,
                            glass_radius_px / sdf_scale,
                            rounding_power) * sdf_scale / size;

  vec3 glass_color;
  if (inverse_sdf < 0.0) {
    glass_color = backdrop_color(target_pixel_coordinates);
  } else {
    vec2 direction = safe_normalize(glass_coordinate);
    float center_distance = 1.0 -
        clamp(inverse_sdf / max(distortion_depth, 0.0001), 0.0, 1.0);
    float distortion = 1.0 - sqrt(max(1.0 - center_distance * center_distance, 0.0));
    vec2 offset = distortion * direction * glass_size * 0.5 * distortion_strength;
    vec2 glass_position = target_pixel_coordinates - offset;
    float edge = center_distance;
    vec2 shift = direction * edge * chromatic_shift_px;
    glass_color = vec3(backdrop_color(glass_position - shift).r,
                       backdrop_color(glass_position).g,
                       backdrop_color(glass_position + shift).b) * glass_tint;
  }

  vec4 color = client + vec4(glass_color, 1.0) * (1.0 - client.a);
  float clip_radius = zwwm_clip_radius;
  float coverage = rounded_rect_coverage(target_pixel_coordinates - zwwm_clip_rect.xy,
                                           zwwm_clip_rect.zw, clip_radius,
                                           rounding_power);
  fragment_color = color * zwwm_opacity * coverage;
}
