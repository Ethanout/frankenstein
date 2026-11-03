#version 330

#if defined(PER_FACE_LIGHTING) || !defined(NO_CARDINAL_LIGHTING)
#moj_import <minecraft:light.glsl>
#endif
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform float FogStart;

#ifndef NO_OVERLAY
uniform sampler2D Sampler1;
#endif

#ifndef EMISSIVE
uniform sampler2D Sampler2;
#endif

out float sphericalVertexDistance;
out float cylindricalVertexDistance;

#ifdef PER_FACE_LIGHTING
out vec4 vertexPerFaceColorBack;
out vec4 vertexPerFaceColorFront;
#else
out vec4 vertexColor;
#endif

#ifndef EMISSIVE
out vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
out vec4 overlayColor;
#endif

out vec2 texCoord0;
flat out int handRemap;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColorBack = minecraft_mix_light_separate(-light, Color);
    vertexPerFaceColorFront = minecraft_mix_light_separate(light, Color);
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif

#ifndef EMISSIVE
    lightMapColor = sample_lightmap(Sampler2, UV2);
#endif

#ifndef NO_OVERLAY
    overlayColor = texelFetch(Sampler1, UV1, 0);
#endif

    texCoord0 = UV0;
    handRemap = 0;

    // Vanilla's first-person item pass has no public camera flag. This is the
    // same uniform-state heuristic used by the upstream pack.
    if (FogStart > 3e38 && ProjMat[2][3] != 0.0) {
        handRemap = 1;
        int face = (gl_VertexID % 48) / 4;
        int vertex = gl_VertexID % 4;
        bool slim = texture(Sampler0, vec2(54.0 / 64.0, 20.0 / 64.0)).a == 0.0;
        ivec4 uv = slim ? ivec4(39, 52, 36, 64) : ivec4(40, 52, 36, 64);
        if (face % 6 == 0) {
            if (vertex == 0) texCoord0 = vec2(uv.xy) / 64.0;
            if (vertex == 1) texCoord0 = vec2(uv.zy) / 64.0;
            if (vertex == 2) texCoord0 = vec2(uv.zw) / 64.0;
            if (vertex == 3) texCoord0 = vec2(uv.xw) / 64.0;
        }
    }

#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif
}
