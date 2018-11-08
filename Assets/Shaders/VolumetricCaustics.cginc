

float4x4 LookAtLH(const float3 eye, const float3 at, const float3 up)
{
	float3 zaxis = normalize(at - eye);
	float3 xaxis = normalize(cross(up, zaxis));
	float3 yaxis = cross(zaxis, xaxis);

	// row major
	return float4x4(
		xaxis.x, yaxis.x, zaxis.x, 0,
		xaxis.y, yaxis.y, zaxis.y, 0,
		xaxis.z, yaxis.z, zaxis.z, 0,
		-dot(xaxis, eye), -dot(yaxis, eye), -dot(zaxis, eye), 1);

	/*return float4x4(
		xaxis.x, yaxis.y, zaxis.z, -dot(xaxis, eye),
		xaxis.x, yaxis.y, zaxis.z, -dot(yaxis, eye),
		xaxis.x, yaxis.y, zaxis.z, -dot(zaxis, eye),
		0, 0, 0, 1);*/
}

float4x4 GetBeamSpaceMatrix(float3 v0, float3 v1, float3 v0Normal)
{
	float3 origin = v0;
	float3 x = v1 - origin;
	float3 y = v0Normal;
	float3 z = cross(x, y);

	return LookAtLH(origin, origin + x, y);
}

bool IsInsideBeamVolume(float3 p, float3 c0, float3 c1, float3 c2)
{
	float beta0 = p.x*(c2.z - c1.z) + p.z*(c1.x - c2.x) + c1.z*c2.x - c1.x*c2.z;

	float beta1 = p.x*(c0.z - c2.z) + p.z*(c2.x - c0.x) + c2.z*c0.x - c2.x*c0.z;

	float beta2 = p.x*(c1.z - c0.z) + p.z*(c0.x - c1.x) + c0.z*c1.x - c0.x*c1.z;

	if ((beta0 > 0 && beta1 > 0 && beta2 > 0) || (beta0 < 0 && beta1 < 0 && beta2 < 0))
	{
		return true;
	}
	else
	{
		return false;
	}
}