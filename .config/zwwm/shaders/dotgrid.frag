#version 300 es
// Dot grid background — порт из driftwm bg.glsl под ABI zwwm.
// zwwm не отдаёт позицию камеры холста, поэтому вместо скролла за канвасом
// сетка медленно дрейфует сама (zwwm_time). Цвета фона берутся из
// values.top_color / bottom_color в config.zw.
precision highp float;

uniform vec2  zwwm_output_size;
uniform vec4  zwwm_config_top_color;
uniform vec4  zwwm_config_bottom_color;
uniform float zwwm_time;

out vec4 fragment_color;

const float DOT_SPACING = 240.0;
const float DOT_RADIUS  = 2.5;   // радиус белого ядра
const float RING_WIDTH  = 1.5;   // толщина кольца
const float AA          = 0.8;   // ширина антиалиасинга

const vec3  DOT_COL  = vec3(1.0);  // белое ядро
const float DOT_A    = 0.95;
const vec3  RING_COL = vec3(0.0);  // чёрное кольцо
const float RING_A   = 0.75;

void main() {
    vec2 px = gl_FragCoord.xy;

    // медленный дрейф вместо привязки к камере
    vec2 scroll = vec2(zwwm_time * 4.0, zwwm_time * 2.0);
    vec2 grid = mod(px + scroll + DOT_SPACING * 0.5, DOT_SPACING)
              - vec2(DOT_SPACING * 0.5);
    float d = length(grid);

    // Белое ядро
    float core = 1.0 - smoothstep(DOT_RADIUS - AA, DOT_RADIUS + AA, d);

    // Кольцо
    float r_outer = DOT_RADIUS + RING_WIDTH;
    float ring = smoothstep(DOT_RADIUS - AA, DOT_RADIUS + AA, d)
               * (1.0 - smoothstep(r_outer - AA, r_outer + AA, d));

    // Лёгкое внешнее свечение
    float glow = (1.0 - smoothstep(r_outer, r_outer + 3.0, d)) * 0.12;

    // База — градиент из конфига
    vec2 uv = px / max(zwwm_output_size, vec2(1.0));
    vec3 col = mix(zwwm_config_bottom_color.rgb, zwwm_config_top_color.rgb, uv.y);

    col = mix(col, RING_COL, clamp(glow * RING_A * 0.4, 0.0, 1.0));
    col = mix(col, RING_COL, ring * RING_A * (1.0 - core));
    col = mix(col, DOT_COL,  core * DOT_A);

    fragment_color = vec4(col, 1.0);
}
