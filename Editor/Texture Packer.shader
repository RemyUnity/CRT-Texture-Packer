Shader "Remy Unity/CRT Texture Packer"
{
	Properties
	{
		[Header(Red)]
		[NoScaleOffset]
		_TexR("Input Texture R", 2D) = "white"{}
		[Enum(RemyUnity.CRTexturePackerEditor.PackerSourceType)]
		_InputModeR("Input Mode R", float) = 0
		_RemapR("Remap R Value", Vector) = (0,1,0,1)

		[Space]
		[Header(Green)]
		[NoScaleOffset]
		_TexG("Input Texture G", 2D) = "white"{}
		[Enum(RemyUnity.CRTexturePackerEditor.PackerSourceType)]
		_InputModeG("Input Mode G", float) = 1
		_RemapG("Remap G Value", Vector) = (0,1,0,1)

		[Space]
		[Header(Blue)]
		[NoScaleOffset]
		_TexB("Input Texture B", 2D) = "white"{}
		[Enum(RemyUnity.CRTexturePackerEditor.PackerSourceType)]
		_InputModeB("Input Mode B", float) = 2
		_RemapB("Remap B Value", Vector) = (0,1,0,1)

		[Space]
		[Header(Alpha)]
		[NoScaleOffset]
		_TexA("Input Texture A", 2D) = "white"{}
		[Enum(RemyUnity.CRTexturePackerEditor.PackerSourceType)]
		_InputModeA("Input Mode A", float) = 3
		_RemapA("Remap A Value", Vector) = (0,1,0,1)

		[Space]
		[Header(Other)]
		_GammaCorrections("Gamma Correction", Vector) = (1,1,1,1)
	}

	SubShader
	{
		Lighting Off
		Blend One Zero

		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag
			#pragma target 3.0

			#define DECLAREINPUTS(x) sampler2D _Tex##x; float _InputMode##x; float4 _Remap##x;
			#define PACKSAMPLE(x) GetTexture(_Tex##x, _InputMode##x, _Remap##x, IN.localTexcoord.xy)

			DECLAREINPUTS(R)
			DECLAREINPUTS(G)
			DECLAREINPUTS(B)
			DECLAREINPUTS(A)

			float4 _GammaCorrections;

			float GetTexture(sampler2D tex, float inputMode, float4 remap, float2 uv)
			{
				int i_InputMode = floor(inputMode);
				float div = remap.y - remap.x;
				div = (abs(div) < 0.001 )? 1 : div;

				float o = 0;

				if (i_InputMode < 4 )
				{
					o = tex2D(tex, uv)[i_InputMode];
				}
				else if (i_InputMode == 4)
				{
					float3 t = tex2D(tex, uv).rgb * float3(0.21,0.72,0.07);
					o = t.r+t.g+t.b;
				}
				else if (i_InputMode == 5)
				{
					float3 t = tex2D(tex, uv).rgb;
					o = (t.r+t.g+t.b)/3.0;
				}
				else if (i_InputMode == 6)
				{
					float3 t = tex2D(tex, uv).rgb;
					o = (min(min(t.r, t.g), t.b) + max(max(t.r, t.g), t.b))*0.5;
				}

				return ((tex2D(tex, uv)[i_InputMode] - remap.x) / div) *(remap.w - remap.z) + remap.z;
				return tex2D(tex, uv).x;
			}

			float4 frag(v2f_customrendertexture IN) : COLOR
			{
				return pow(
					float4(
					PACKSAMPLE(R),
					PACKSAMPLE(G),
					PACKSAMPLE(B),
					PACKSAMPLE(A)
					),
					_GammaCorrections
					);
			}
			ENDCG
		}
	}
}
