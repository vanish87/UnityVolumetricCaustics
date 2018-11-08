using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

namespace UnityTools
{
    public class Math
    {
        static public Vector3 Refract(Vector3 input, Vector3 normal, float n1, float n2)
        {
            Assert.IsTrue(false, "Not correct");

            input.Normalize();
            normal.Normalize();

            //inverse direction
            Assert.IsTrue(Vector3.Dot(input, normal) <= 0);

            float c = n1 / n2;
            float cos_in = -Vector3.Dot(input, normal);
            float sin_out2 = c * c * (1 - (cos_in * cos_in));

            float so2 = 1 - (sin_out2 * sin_out2);
            Assert.IsTrue(so2 > 0);

            Vector3 ret = (c * input) + (c * cos_in - Mathf.Sqrt(so2)) * normal;

            return ret;
        }
    }
}
