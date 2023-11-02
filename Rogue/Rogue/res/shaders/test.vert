#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoord;
layout (location = 3) in vec3 aTangent;
layout (location = 4) in vec3 aBitangent;
layout (location = 5) in ivec4 aBoneID;
layout (location = 6) in vec4 aBoneWeight;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec2 TexCoord;
out vec3 WorldPos;
out vec3 WorldPosPrevious;

out vec3 attrNormal;
out vec3 attrTangent;
out vec3 attrBiTangent;

uniform int tex_flag;

uniform bool isAnimated;
uniform mat4 skinningMats[85];

void main() {


	if (isAnimated) {

		TexCoord = aTexCoord;	
		//vec4 worldPos;
		vec4 totalLocalPos = vec4(0.0);
		vec4 totalNormal = vec4(0.0);
		vec4 totalTangent = vec4(0.0);
		vec4 totalBiTangent = vec4(0.0);
			
		vec4 vertexPosition =  vec4(aPos, 1.0);
		vec4 vertexNormal = vec4(aNormal, 0.0);
		vec4 vertexTangent = vec4(aTangent, 0.0);
		vec4 vertexBiTangent = vec4(aBitangent, 0.0);

		for(int i=0;i<4;i++)  {
			mat4 jointTransform = skinningMats[int(aBoneID[i])];
			vec4 posePosition =  jointTransform  * vertexPosition * aBoneWeight[i];
			
			vec4 worldNormal = jointTransform * vertexNormal * aBoneWeight[i];
			vec4 worldTangent = jointTransform * vertexTangent * aBoneWeight[i];
			vec4 worldBiTangent = jointTransform * vertexBiTangent * aBoneWeight[i];

			totalLocalPos += posePosition;		
			totalNormal += worldNormal;	
			totalTangent += worldTangent;	
			totalBiTangent += worldBiTangent;
		}
	
		WorldPos = (model * vec4(totalLocalPos.xyz, 1)).xyz;
		//WorldPos = aPos;
		//WorldPos.y += 1;
		
		attrNormal = normalize(totalNormal.xyz);
		attrTangent = normalize(totalTangent.xyz);
		attrBiTangent = normalize(totalBiTangent.xyz);

		attrBiTangent = normalize(cross(attrNormal,attrTangent));
		
		gl_Position = projection * view * vec4(WorldPos, 1.0);
	}

	// NOT ANIMATED
	else {	
		attrNormal = (model * vec4(aNormal, 0)).xyz;
		attrTangent = (model * vec4(aTangent, 0.0)).xyz;
		attrBiTangent = (model * vec4(aBitangent, 0.0)).xyz;

		TexCoord = aTexCoord;
		WorldPos = (model * vec4(aPos.x, aPos.y, aPos.z, 1.0)).xyz;
				
		gl_Position = projection * view * vec4(WorldPos, 1.0);
	}
}