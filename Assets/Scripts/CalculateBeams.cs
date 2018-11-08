using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Assertions;
using UnityTools;
using UnityTools.LightCamera;

namespace VolumetricCaustics
{
    [ExecuteInEditMode]
    public class CalculateBeams : MonoBehaviour
    {

        [StructLayout(LayoutKind.Explicit, Size = 12 * 3)]
        public struct Triangle
        {
            [FieldOffset(0)]
            public Vector3 a;
            [FieldOffset(12)]
            public Vector3 b;
            [FieldOffset(24)]
            public Vector3 c;
        }
        [StructLayout(LayoutKind.Explicit, Size = 36 * 3)]
        public struct Beam
        {
            [FieldOffset(0)]
            public Triangle pos;

            [FieldOffset(36)]
            public Triangle normal;

            [FieldOffset(72)]
            public Triangle refrect;
        }

        private readonly int numberOfBeams = 32 * 32;
        private ComputeBuffer beamsBuffer = null;

        private int kernalID = -1;
        [SerializeField] private ComputeShader cs = null;

        [SerializeField] private float refractionIndex = 1;
        [SerializeField] private float volumeLength = 1;

        public CameraRender gbuffer = null;
        public CameraRender recieverGBuffer = null;
        public LightCamera lightCamera = null;
        public Beam[] output = null;

        [SerializeField] private Material mat = null;
        [SerializeField] private int renderingIndex = 0;

        // Use this for initialization
        void Start()
        {
            int size = Marshal.SizeOf<Beam>();// + Marshal.SizeOf(typeof(float)) * 4;
            Assert.IsTrue(size == Marshal.SizeOf<Vector3>() * 3 * 3);
            this.beamsBuffer = new ComputeBuffer(numberOfBeams, size);

            Assert.IsNotNull(this.beamsBuffer);
            Assert.IsNotNull(this.cs);

            this.kernalID = this.cs.FindKernel("CSMain");

            this.output = new Beam[this.numberOfBeams];

            this.mat = new Material(Shader.Find("Custom/DrawBeamVolume"));
        }

        /*void RunTest()
        {
            var lightPos = this.gbuffer.transform.position;
            Debug.Log("LightPos " + lightPos);

            //var b = this.output[25];
            foreach (var b in this.output)
            {
                Debug.Log("pos in " + b.pos.ToString("F3"));
                Debug.Log("normal " + b.normal.ToString("F3"));
                Debug.Log("gpu refrect " + b.refrect.ToString("F3"));

                var input = (b.pos - lightPos).normalized;
                var cos1 = Vector3.Dot(-input, b.normal);
                var left = Mathf.Sqrt(1 - cos1 * cos1);
                Debug.Log("Sin1 x 1 =" + left.ToString("F3"));

                var cos2 = Vector3.Dot(b.refrect.normalized, -b.normal);
                var right = (Mathf.Sqrt(1 - cos2 * cos2) * 1.33f);
                Debug.Log("Sin2 x 1.33 =" + right.ToString("F3"));

                //Verify Snell's law
                if (cos1 > 0 && cos2 > 0)
                {
                    Assert.IsTrue(Mathf.Approximately(left, right));
                }
            }
        }*/

        // Update is called once per frame
        void Update()
        {
            if (this.kernalID != -1)
            {
                //this.refractionIndex = 1 / 1.33f;
                var lightPos = lightCamera.IsDirection() ? lightCamera.Direction():this.gbuffer.transform.position;
                this.cs.SetTexture(this.kernalID, "PosTex", this.gbuffer.GBuffer[0]);
                this.cs.SetTexture(this.kernalID, "NormalTex", this.gbuffer.GBuffer[1]);
                this.cs.SetVector("LightPos", lightPos);
                this.cs.SetVector("LightParamters", new Vector4(this.refractionIndex, lightCamera.IsDirection()?1:0, 0,0));
                this.cs.SetBuffer(this.kernalID, "Result", this.beamsBuffer);
                this.cs.Dispatch(this.kernalID, 1, 1, 1);

                this.beamsBuffer.GetData(this.output);
            }
        }

        private void OnDrawGizmos()
        {
            if (this.output != null )
            {
                foreach (var b in this.output)
                {
                    Gizmos.DrawSphere(b.pos.a, 0.05f);
                    Gizmos.DrawRay(new Ray(b.pos.a, b.refrect.a));
                    //Gizmos.DrawRay(new Ray(b.pos.a, b.normal.a));
                }
            }
        }

        private void OnRenderObject()
        {
            Assert.IsNotNull(this.mat);
            this.mat.SetPass(0);
            this.mat.SetBuffer("beamBuffer", this.beamsBuffer);
            this.mat.SetTexture("recieverGBuffer", this.recieverGBuffer.GBuffer[0]);
            this.mat.SetMatrix("invViewMat", this.lightCamera.TargetCamera().worldToCameraMatrix.inverse);
            this.mat.SetFloat("volumeLength", this.volumeLength);
            this.mat.SetInt("renderingIndex", this.renderingIndex);

            Graphics.DrawProcedural(MeshTopology.Points, 1);
        }
    }
}