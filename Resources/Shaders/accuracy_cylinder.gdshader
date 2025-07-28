// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_front, diffuse_burley, specular_schlick_ggx, unshaded, fog_disabled;

//uniform float angle = 0.0;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
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

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

void fragment() {
	vec2 base_uv = UV;
	float threshold = 0.01;
	float lines = 16.0;
	float wibbles_count = 16.0;
	
	float wibbly = (sin((UV.x + TIME * 0.01)*TAU*wibbles_count) + sin((UV.x + TIME * 0.037)*TAU*wibbles_count)) * 0.01;
	float timescale = 0.05;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	//ALBEDO.rgb = vec3(mod(UV.x*4.0+TIME*0.2,1.0));

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	ALPHA *= albedo.a * albedo_tex.a + 1.0 - albedo_tex.a * step(threshold, mod((wibbly + UV.y*lines-(TIME*timescale)+random(SCREEN_UV-TIME)*0.01),1.0)) * step(0.00, random(SCREEN_UV+TIME*6.23));
}
