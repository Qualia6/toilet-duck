shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform sampler2D noise_texture;
uniform vec4 albedo : source_color;

uniform float y_at;
uniform float fog_thicc;
//uniform float feathering;
//uniform float animation;
//uniform float animation_scale;
//uniform float noise_scale;

void vertex() {
	POSITION = (vec4(UV.x*2.-1., UV.y*2.-1., 0., 1.0) );
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	vec3 ndc = vec3((SCREEN_UV * 2.0) - 1.0, depth*2.-1.);
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = length(view.xyz);
	
	const float farPlane = 4000.;
	const float nearPlane = 0.05;
	
	vec4 clipCoords = vec4(
		SCREEN_UV*2. - 1.,
		depth * (farPlane - nearPlane) + nearPlane,
		1.
	);
	
	float camera_off_set_from_fog_start_line = (CAMERA_POSITION_WORLD.y - y_at);
	
	vec3 world_view = normalize((INV_VIEW_MATRIX * vec4(view.xyz, 0.)).xyz);
	//vec3 cast_position = normalize((INV_VIEW_MATRIX * vec4(view.xyz, 1.)).xyz);
	
	float fog;
	if (camera_off_set_from_fog_start_line > 0.) { // at the top
		if (world_view.y > 0.) { // looking up
			discard;
		} else { // looking down
			float distance_to_fog_plane = camera_off_set_from_fog_start_line/-world_view.y;
			fog = max(linear_depth - distance_to_fog_plane, 0.);
		}
	} else { // at the bottom
		if (world_view.y > 0.) { // looking up
			float distance_to_fog_plane = camera_off_set_from_fog_start_line/-world_view.y;
			fog = min(distance_to_fog_plane, linear_depth);
		} else { // looking down
			fog = linear_depth;
		}
	}
	
	ALBEDO = albedo.xyz;
	ALPHA = 1.-exp(-fog*fog_thicc);
}



//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
