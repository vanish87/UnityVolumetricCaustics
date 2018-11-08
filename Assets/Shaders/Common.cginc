

struct Triangle
{
	float3 a;
	float3 b;
	float3 c;
};
struct Beam
{
	Triangle pos;
	Triangle normal;
	Triangle refraction;
};