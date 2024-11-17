// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode vertex_lighting, specular_schlick_ggx, diffuse_lambert_wrap;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float alpha : hint_range(1.0, 0.);

varying float vertex_distance;

void vertex() {
	vec3 model_vert = (MODEL_MATRIX * vec4(VERTEX, 1)).xyz;
	VERTEX.x += model_vert.x - (round(model_vert.x * 20.) / 20.);
	VERTEX.y += model_vert.y - (round(model_vert.y * 20.) / 20.);
	VERTEX.z += model_vert.z - (round(model_vert.z * 20.) / 20.);
	UV = UV * uv1_scale.xy + uv1_offset.xy;


    vertex_distance = length((MODEL_MATRIX * vec4(VERTEX, 1.0)));
}


float get_dither_brightness(vec3 given_color, vec4 fragcoord) {

    int x = int(fragcoord.x) % 4;
    int y = int(fragcoord.y) % 4;
    const vec3 luminance = vec3(0.2126, 0.7152, 0.0722);
    float calculated_brightness = (luminance.r * given_color.r) + (luminance.g * given_color.g) + (luminance.b * given_color.b);


    float thresholdMatrix[16] = float[16] (
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    );

    float dithering = thresholdMatrix[x * 4 + y];

    if ((calculated_brightness - 0.2 < dithering) && (vertex_distance < 60.)) {
        return ((dithering - 0.5) * 0.25) + 1.0;
    } else {
        return 1.;
    }
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb * get_dither_brightness( albedo_tex.rgb, FRAGCOORD);;
	ALPHA = alpha;
	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
}
