attribute vec3 attribute_grassOffset;
attribute float attribute_grassAngleY;
uniform float uniform_grass_data[9];
uniform float uniform_squeeze_data[6];

uniform mat4 uniform_cameraMatrix;
uniform mat4 uniform_billboardMatrix;

varying vec4 varying_mvPose; 
const float TrueOrFalse = 0.5;
const float PI_2 = 6.283;

struct SqueezeData{
	float enable;
	vec3 position;
	float strength;
	float radius;
};

SqueezeData squeezeData;


mat4 buildRotMat4(vec3 rot)
{
	//____________
	float s;
	float c;

	s = sin(rot.x);
	c = cos(rot.x);
	
	mat4 ret = mat4(
	vec4(1.0, 0.0, 0.0, 0.0),
	vec4(0.0, c, s, 0.0),
	vec4(0.0, -s, c, 0.0),
	vec4(0.0, 0.0, 0.0, 1.0)
	);
	
	//____________
	s = sin(rot.y);
	c = cos(rot.y);
	
	ret = mat4(
	vec4(c, 0.0, -s, 0.0),
	vec4(0.0, 1.0, 0.0, 0.0),
	vec4(s, 0.0, c, 0.0),
	vec4(0.0, 0.0, 0.0, 1.0)
	) * ret;


	//____________
	s = sin(rot.z);
	c = cos(rot.z);

	ret = mat4(
	vec4(c, s, 0.0, 0.0),
	vec4(-s, c, 0.0, 0.0),
	vec4(0.0, 0.0, 1.0, 0.0),
	vec4(0.0, 0.0, 0.0, 1.0)
	) * ret;

	return ret;
}
void main(void){

	
	if(uniform_grass_data[8] > TrueOrFalse){
		rotVertexMatrix = uniform_billboardMatrix;
	}else{
		rotVertexMatrix = buildRotMat4(vec3(0.0, attribute_grassAngleY, 0.0));
	}
	e_position.xyz = (rotVertexMatrix * vec4(e_position, 1.0)).xyz;
	e_normal.xyz = (rotVertexMatrix * vec4(e_normal, 1.0)).xyz;

	if(e_position.y > 0.0){ 
		float windDirectionX			= uniform_grass_data[0];
		float windDirectionZ			= uniform_grass_data[1];
		float windSpaceX				= uniform_grass_data[2];
		float windSpaceZ				= uniform_grass_data[3];
		float windStrength				= uniform_grass_data[4];
		float windSpeed					= uniform_grass_data[5];
		float shakeScale				= uniform_grass_data[6];
		float grassTime					= uniform_grass_data[7];

		squeezeData.enable			= uniform_squeeze_data[0];
		squeezeData.position.x		= uniform_squeeze_data[1];
		squeezeData.position.y		= uniform_squeeze_data[2];
		squeezeData.position.z		= uniform_squeeze_data[3];
		squeezeData.radius			= uniform_squeeze_data[4];
		squeezeData.strength		= uniform_squeeze_data[5];

		windSpaceX = PI_2 * (attribute_grassOffset.x + abs(windDirectionX) * windSpeed * grassTime) / windSpaceX;
		windSpaceZ = PI_2 * (attribute_grassOffset.z + abs(windDirectionZ) * windSpeed * grassTime) / windSpaceZ;
		
		e_position.x += windDirectionX * (sin(windSpaceX + windSpaceZ) * shakeScale + windStrength) * e_position.y;
		e_position.z += windDirectionZ * (sin(windSpaceX + windSpaceZ) * shakeScale + windStrength) * e_position.y;

		//��ѹ
		if(squeezeData.enable > TrueOrFalse){
			vec3 distanceVec3 = squeezeData.position - attribute_grassOffset;
			float distanceFloat = sqrt(dot(distanceVec3, distanceVec3));
			if(distanceFloat < squeezeData.radius){
				float ratio = distanceFloat / squeezeData.radius;
				ratio = 1.0 - ratio;
				distanceVec3 = normalize(distanceVec3);
				distanceVec3 *= squeezeData.strength * ratio * abs(e_position.y - squeezeData.position.y);
				e_position -= distanceVec3;
			}
		}
	}


	e_position += attribute_grassOffset;
	mat4 mvMatrix = mat4(uniform_ViewMatrix * uniform_ModelMatrix);
	varying_mvPose = outPosition = mvMatrix * vec4( e_position , 1.0 ); 
    
    mat4 normalMatrix = inverse(mvMatrix) ;
    normalMatrix = transpose(normalMatrix); 

    varying_eyeNormal = mat3(normalMatrix) * - e_normal; 
    varying_color = attribute_color; 
    
}
