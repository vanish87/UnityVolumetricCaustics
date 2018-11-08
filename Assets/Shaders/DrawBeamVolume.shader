Shader "Custom/DrawBeamVolume"
{
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		//to make intensity in frag shader working
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma enable_d3d11_debug_symbols


			#include "UnityCG.cginc"
			#include "Assets/Shaders/Common.cginc"
			#include "Assets/Shaders/VolumetricCaustics.cginc"

			StructuredBuffer<Beam> beamBuffer;
			float4x4 invViewMat;
			float volumeLength;
			int renderingIndex;

			struct vIn
			{
				uint index : SV_VERTEXID;
			};

			struct v2g
			{
				float3 positionA : TEXCOORD0;
				float3 positionB : TEXCOORD1;
				float3 positionC : TEXCOORD2;
				float3 refractA : TEXCOORD3;
				float3 refractB : TEXCOORD4;
				float3 refractC : TEXCOORD5;


				float3 normalA : TEXCOORD6;
				float3 normalB : TEXCOORD7;
				float3 normalC : TEXCOORD8;
											 
			};

			struct g2f
			{
				float4 position : SV_POSITION;
				float4 uv		: TEXCOORD0;
				float3 color	: COLOR;

				float3 v0 : TEXCOORD1;
				float3 v1 : TEXCOORD2;
				float3 v2 : TEXCOORD3;

				float3 r0: TEXCOORD4;
				float3 r1: TEXCOORD5;
				float3 r2: TEXCOORD6;

				float3 v0NormalWS : TEXCOORD7;
			};
			
			v2g vert(vIn v)
			{
				v.index = renderingIndex;
				v2g o = (v2g)0;
				o.positionA = beamBuffer[v.index].pos.a;
				o.positionB = beamBuffer[v.index].pos.b;
				o.positionC = beamBuffer[v.index].pos.c;

				o.refractA = beamBuffer[v.index].refraction.a;
				o.refractB = beamBuffer[v.index].refraction.b;
				o.refractC = beamBuffer[v.index].refraction.c;

				o.normalA = beamBuffer[v.index].normal.a;
				o.normalB = beamBuffer[v.index].normal.b;
				o.normalC = beamBuffer[v.index].normal.c;
				//o.position = float4(v.index,0,0,1);
				return o;
			}

			static const float3 g_positions[4] =
			{
				float3(-1, 1, 0),
				float3(1, 1, 0),
				float3(-1,-1, 0),
				float3(1,-1, 0),
			};

			static const float2 g_texcoords[4] =
			{
				float2(0, 0),
				float2(1, 0),
				float2(0, 1),
				float2(1, 1),
			};

			void AddTriangle(g2f v1, g2f v2, g2f v3, inout TriangleStream<g2f> out_stream)
			{
				out_stream.Append(v1);
				out_stream.Append(v2);
				out_stream.Append(v3); 
				out_stream.RestartStrip();
			}

			void AddRectangle(g2f v1, g2f v2, g2f v3, g2f v4, inout TriangleStream<g2f> out_stream)
			{
				out_stream.Append(v1);
				out_stream.Append(v2);
				out_stream.Append(v3);
				out_stream.Append(v4);
				out_stream.RestartStrip();
			}

			[maxvertexcount(12)]
			void geom(point v2g v[1], inout TriangleStream<g2f> out_stream)
			{
				g2f v0 = (g2f)0;
				g2f v1 = (g2f)0;
				g2f v2 = (g2f)0;

				g2f c0 = (g2f)0;
				g2f c1 = (g2f)0;
				g2f c2 = (g2f)0;

				float3 red = float3(1, 0, 0);
				float3 green = float3(0, 1, 0);
				float3 blue = float3(0, 0, 1);
				float3 white = float3(1, 1, 1);

				v0.position = UnityObjectToClipPos(float4(v[0].positionA, 1.0));
				v0.uv = ComputeScreenPos(v0.position);
				v0.color = white;

				
				v1.position = UnityObjectToClipPos(float4(v[0].positionB, 1.0));
				v1.uv = ComputeScreenPos(v1.position);
				v1.color = white;


				v2.position = UnityObjectToClipPos(float4(v[0].positionC, 1.0));
				v2.uv = ComputeScreenPos(v2.position);
				v2.color = white;


				float3 new_posA = v[0].positionA + v[0].refractA * volumeLength;
				float3 new_posB = v[0].positionB + v[0].refractB * volumeLength;
				float3 new_posC = v[0].positionC + v[0].refractC * volumeLength;

				c0.position = UnityObjectToClipPos(float4(new_posA, 1.0));
				c0.uv = ComputeScreenPos(c0.position);
				c0.color = white;


				c1.position = UnityObjectToClipPos(float4(new_posB, 1.0));
				c1.uv = ComputeScreenPos(c1.position);
				c1.color = white;


				c2.position = UnityObjectToClipPos(float4(new_posC, 1.0));
				c2.uv = ComputeScreenPos(c2.position);
				c2.color = white;


				//normal

				v0.v0NormalWS = v[0].normalA;
				v1.v0NormalWS = v[0].normalA;
				v2.v0NormalWS = v[0].normalA;

				c0.v0NormalWS = v[0].normalA;
				c1.v0NormalWS = v[0].normalA;
				c2.v0NormalWS = v[0].normalA;

				//vertex------------------

				v0.v0 = v[0].positionA;
				v0.v1 = v[0].positionB;
				v0.v2 = v[0].positionC;

				v1.v0 = v[0].positionA;
				v1.v1 = v[0].positionB;
				v1.v2 = v[0].positionC;

				v2.v0 = v[0].positionA;
				v2.v1 = v[0].positionB;
				v2.v2 = v[0].positionC;


				c0.v0 = v[0].positionA;
				c0.v1 = v[0].positionB;
				c0.v2 = v[0].positionC;

				c1.v0 = v[0].positionA;
				c1.v1 = v[0].positionB;
				c1.v2 = v[0].positionC;

				c2.v0 = v[0].positionA;
				c2.v1 = v[0].positionB;
				c2.v2 = v[0].positionC;

				//refract---------------

				v0.r0 = v[0].refractA;
				v0.r1 = v[0].refractB;
				v0.r2 = v[0].refractC;

				v1.r0 = v[0].refractA;
				v1.r1 = v[0].refractB;
				v1.r2 = v[0].refractC;

				v2.r0 = v[0].refractA;
				v2.r1 = v[0].refractB;
				v2.r2 = v[0].refractC;


				c0.r0 = v[0].refractA;
				c0.r1 = v[0].refractB;
				c0.r2 = v[0].refractC;

				c1.r0 = v[0].refractA;
				c1.r1 = v[0].refractB;
				c1.r2 = v[0].refractC;

				c2.r0 = v[0].refractA;
				c2.r1 = v[0].refractB;
				c2.r2 = v[0].refractC;

				

				//AddTriangle(v0, v1, v2, out_stream);
				//AddTriangle(c0, c1, c2, out_stream);
				//return;
				/*
				v0.color = red;
				v1.color = red;
				v2.color = red;
				c0.color = red;
				c1.color = red;
				c2.color = red;
				*/
				out_stream.Append(v0);
				out_stream.Append(c0);
				out_stream.Append(v1);	
				out_stream.Append(c1);
				out_stream.RestartStrip();
				/*
				v0.color = green;
				v1.color = green;
				v2.color = green;
				c0.color = green;
				c1.color = green;
				c2.color = green;
				*/
				out_stream.Append(v1);
				out_stream.Append(c1);
				out_stream.Append(v2);
				out_stream.Append(c2);
				out_stream.RestartStrip();


				/*
				v0.color = blue;
				v1.color = blue;
				v2.color = blue;
				c0.color = blue;
				c1.color = blue;
				c2.color = blue;
				*/
				out_stream.Append(v2);
				out_stream.Append(c2);
				out_stream.Append(v0);
				out_stream.Append(c0);
				out_stream.RestartStrip();
				//AddTriangle(v0, v1, v2, out_stream);
				//AddTriangle(c0, c1, c2, out_stream);

				//AddTriangle(v0, c0, c1, out_stream);
				//AddTriangle(v0, c1, v2, out_stream);

				//AddTriangle(v1, c1, c2, out_stream);
				//AddTriangle(v1, c2, v2, out_stream);

				//AddTriangle(v2, c2, c1, out_stream);
				//AddTriangle(v2, c0, v0, out_stream);

				//out_stream.RestartStrip();
			}


			sampler2D recieverGBuffer;

			fixed4 frag(g2f i) : SV_Target
			{
				// sample the texture
				float3 col = i.color;

				//all position is in "Beam Space" now
				float4 pos = tex2Dproj(recieverGBuffer, i.uv);

				if (pos.x == 0 && pos.y == 0 && pos.z == 0) return fixed4(0,1,0,1);

				float3 v0 = i.v0;
				float3 v1 = i.v1;
				float3 v2 = i.v2;
				
				float3 normal = i.v0NormalWS;

				float4x4 mat = LookAtLH(v0, v1, -normal);
				
				float3 newPos = mul(float4(pos.rgb, 1), mat);

				float3 r0 = mul(i.r0, (float3x3)mat);
				float3 r1 = mul(i.r1, (float3x3)mat);
				float3 r2 = mul(i.r2, (float3x3)mat);

				v0 = mul(float4(v0, 1), mat);
				v1 = mul(float4(v1, 1), mat);
				v2 = mul(float4(v2, 1), mat);

				//scale y to 1
				r0 /= r0.y;
				r1 /= r1.y;
				r2 /= r2.y;

				float alpha = newPos.y;
				float3 c0 = v0 + alpha * r0;
				float3 c1 = v0 + alpha * r1;
				float3 c2 = v0 + alpha * r2;

				if (IsInsideBeamVolume(newPos, c0, c1, c2))
				{
					col.xyz = float3(1, 0, 0);
				}
				else
				{
					col.xyz = float3(0, 0, 0);
				}

				//float3 posLocal = mul()
				//float alpha
				//return fixed4(i.uv.xy / i.uv.w, 0, 1);
				return fixed4(col.xyz, 1);

			}
			ENDCG
		}
	}
}
