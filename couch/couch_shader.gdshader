shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform float specular : hint_range(0.0, 1.0, 0.01);

uniform vec3 albedo : source_color;
uniform sampler2D normal_rough_ao_texture : filter_linear_mipmap, repeat_enable;
uniform sampler2D couch_ao_texture : filter_linear_mipmap, repeat_disable;

uniform float uv_scale;

uniform float normal_scale;


void fragment() {
	vec2 material_uv = UV * uv_scale;
	ALBEDO = albedo;
	SPECULAR = specular;

	vec4 sample = texture(normal_rough_ao_texture, material_uv);

	AO = sample.w * texture(couch_ao_texture, UV).x;
	AO_LIGHT_AFFECT = 1.;

	ROUGHNESS = sample.z;

	NORMAL_MAP = vec3(sample.xy,0.);
	NORMAL_MAP_DEPTH = normal_scale;
}
