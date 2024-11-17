
// NOTE: Shader automatically converted from Godot Engine 4.3.stable's FogMaterial.

shader_type fog;

uniform float density : hint_range(0, 1, 0.0001) = 1.0;
uniform vec4 albedo : source_color = vec4(1.0);
uniform vec4 emission : source_color = vec4(0, 0, 0, 1);
uniform float height_falloff = 0.0;
uniform float edge_fade = 0.1;
uniform sampler3D density_texture: hint_default_white, repeat_enable;
uniform sampler3D detail_texture: hint_default_white, repeat_enable;

uniform float scatter_co : hint_range(0, 1) = 0.1;
uniform float absorb_co : hint_range(0, 1) = 0.05;
uniform vec3 rayleigh_color : source_color = vec3(0.5, 0.7, 1.0);
uniform float rayleigh_intensity : hint_range(0, 10) = 1.0;

uniform vec3 sun_direction : source_color = vec3(0.0, -1.0, 0.0);
uniform vec3 camera_position : source_color = vec3(1.0, 0.0, 0.0);
uniform float phase_factor : hint_range(-1.0, 1.0) = 0.0;

uniform vec3 flow_direction;

void fog() {
    // Compute basic fog density and height attenuation
    float height_factor = clamp(exp2(-height_falloff * (WORLD_POSITION.y - OBJECT_POSITION.y)), 0.0, 1.0);
    DENSITY = (density * 16.) * height_factor;

	float fog_distance = 2.0;
	float distance_to_camera = length(WORLD_POSITION - camera_position);
	float fog_factor = clamp((distance_to_camera - 2.) / fog_distance, 0.0, 1.0);  // Exponential falloff for smoother fog transition
	// Adjust for the edge fade
	fog_factor = pow(fog_factor, edge_fade);
	// Clamp the fog factor to be within [0, 1]
	fog_factor = clamp(fog_factor, 0.0, 1.0);
	// Apply the fog density
	DENSITY *= fog_factor;

	// Modulate with textures for details
    float d_time = TIME * 0.05;
    vec3 time_UV = vec3(WORLD_POSITION.x / 10.0 + d_time * flow_direction.x,
                        WORLD_POSITION.y / 10.0 + d_time * flow_direction.y,
                        WORLD_POSITION.z / 10.0 + d_time * flow_direction.z);
    DENSITY *= texture(density_texture, time_UV).r * 2.0;
    DENSITY -= texture(detail_texture, time_UV).r * (1.0 - SDF) * 2.0;
    DENSITY *= pow(clamp(-2.0 * SDF / min(min(SIZE.x, SIZE.y), SIZE.z), 0.0, 1.0), edge_fade);

	DENSITY *= fog_factor;
    // Calculate view and light angle dependence

    vec3 view_dir = normalize(WORLD_POSITION - camera_position); // View direction
    vec3 light_dir = normalize(sun_direction); // Light direction
    // Angle-based scattering (Henyey-Greenstein phase function approximation)
    float cos_theta = dot(view_dir, light_dir);
    float phase = (1.0 - phase_factor * phase_factor) / pow(1.0 + phase_factor * phase_factor - 2.0 * phase_factor * cos_theta, 1.5);

    // Rayleigh scattering with enhanced scattering intensity
    vec3 rayleigh_scatter = rayleigh_color * rayleigh_intensity * phase * DENSITY;

    // Absorption: Reduces fog visibility based on density
    float absorption = absorb_co * DENSITY;

    // Final ALBEDO combining scattering, absorption, and fog effect
    ALBEDO = albedo.rgb * (1.0 - absorption) + rayleigh_scatter;

    // Optional emission effect (glowing fog)
    EMISSION = emission.rgb * DENSITY;
}