using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

[ExecuteInEditMode]
public class SpaceTextureGenerator : MonoBehaviour
{
    [Header("Output")]
    public Texture2D backgroundTextureOutput;
    public Texture2D starsTextureOutput;
    public Material materialOutput;
    [Header("Activate")]
    public Vector2 textureSize;
    public bool setTexture = false;
    public bool saveTextures = false;
    [Header("Colors")]
    public Color backgroundColor;
    public Color[] starColors;
    [Header("Stars")]
    public int starAmount;
    public int starMinSize;
    public int starMaxSize;
    [Header("Noise")]
    public float noiseScale;
    public float noiseStrength;
    public float maxOffset;
    public float noiseEdgeFadeoff;

    private void Start()
    {
    }

    private void Update()
    {
        if (setTexture)
        {
            GenerateTexture();
            setTexture = false;
        }
        if (saveTextures)
        {
            SaveTextures();
            saveTextures = false;
        }
    }

    public void GenerateTexture()
    {
        //make background texture
        GenerateBackground();

        //make star texture
        GenerateStars();

        //set textures
        materialOutput.SetTexture("_MainTex", backgroundTextureOutput);
        materialOutput.SetTexture("_StarTex", starsTextureOutput);
    }
    
    void GenerateBackground()
    {
        backgroundTextureOutput = new Texture2D((int)textureSize.x, (int)textureSize.y, TextureFormat.ARGB32, false);
        float randomOffsetX = Random.RandomRange(-maxOffset, maxOffset);
        float randomOffsetY = Random.RandomRange(-maxOffset, maxOffset);
        for (int x = 0; x < backgroundTextureOutput.width; x++)
        {
            for (int y = 0; y < backgroundTextureOutput.height; y++)
            {
                float noise = CalculatePerlinFloat(x, y, backgroundTextureOutput.width, backgroundTextureOutput.height, noiseScale, randomOffsetX, randomOffsetX);
                noise *= noiseStrength;

                backgroundTextureOutput.SetPixel(x, y, backgroundColor * noise);
                if (x > backgroundTextureOutput.width - noiseEdgeFadeoff)
                {
                    float falloff = 1 - (backgroundTextureOutput.width - x) / noiseEdgeFadeoff;
                    backgroundTextureOutput.SetPixel(x, y, Color.Lerp(backgroundTextureOutput.GetPixel(x, y), backgroundTextureOutput.GetPixel(1, y), falloff));
                }
                if (y > backgroundTextureOutput.width - noiseEdgeFadeoff)
                {
                    float falloff = 1 - (backgroundTextureOutput.height - y) / noiseEdgeFadeoff;
                    backgroundTextureOutput.SetPixel(x, y, Color.Lerp(backgroundTextureOutput.GetPixel(x, y), backgroundTextureOutput.GetPixel(x, 1), falloff));
                }
            }
        }

        backgroundTextureOutput.Apply();
    }

    void GenerateStars()
    {
        //clear texture
        starsTextureOutput = new Texture2D((int)textureSize.x, (int)textureSize.y, TextureFormat.ARGB32, false);
        for (int x = 0; x < starsTextureOutput.width; x++)
        {
            for (int y = 0; y < starsTextureOutput.height; y++)
            {
                starsTextureOutput.SetPixel(x, y, Color.clear);
            }
        }

        //put down stars
        for (int i = 0; i < starAmount; i++)
        {
            int randomXCoord = Random.Range(0, starsTextureOutput.width);
            int randomYCoord = Random.Range(0, starsTextureOutput.height);
            Color randomColor = starColors[Random.Range(0, starColors.Length)];
            int randomSize = Random.Range(starMinSize, starMaxSize);

            int pixelsDoneX = 0;
            int pixelsDoneY = 0;
            for (int s = 0; s < randomSize * randomSize; s++)
            {
                if (pixelsDoneX == randomSize)
                {
                    pixelsDoneX = 0;
                    pixelsDoneY++;
                }
                starsTextureOutput.SetPixel(randomXCoord + pixelsDoneX, randomYCoord + pixelsDoneY, randomColor);
                pixelsDoneX++;
            }

            //round big star corners
            if (randomSize > 5)
            {
                starsTextureOutput.SetPixel(randomXCoord, randomYCoord, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + 1, randomYCoord, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord, randomYCoord + 1, Color.clear);

                starsTextureOutput.SetPixel(randomXCoord + randomSize - 1, randomYCoord, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + randomSize - 2, randomYCoord, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + randomSize - 1, randomYCoord + 1, Color.clear);

                starsTextureOutput.SetPixel(randomXCoord, randomYCoord + randomSize - 1, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord, randomYCoord + randomSize - 2, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + 1, randomYCoord + randomSize - 1, Color.clear);

                starsTextureOutput.SetPixel(randomXCoord + randomSize - 1, randomYCoord + randomSize - 1, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + randomSize - 2, randomYCoord + randomSize - 1, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + randomSize - 1, randomYCoord + randomSize - 2, Color.clear);

            }
            //round small star corners
            else if (randomSize > 2)
            {
                starsTextureOutput.SetPixel(randomXCoord, randomYCoord, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + randomSize - 1, randomYCoord, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord, randomYCoord + randomSize - 1, Color.clear);
                starsTextureOutput.SetPixel(randomXCoord + randomSize - 1, randomYCoord + randomSize - 1, Color.clear);
            }
        }

        starsTextureOutput.Apply();
    }

    void SaveTextures()
    {
        byte[] data = backgroundTextureOutput.EncodeToPNG();
        File.WriteAllBytes(Application.dataPath + "/SpaceTextures/space_background.png", data);
        print(Application.dataPath + "/SpaceTextures/space_background.png");
        data = starsTextureOutput.EncodeToPNG();
        File.WriteAllBytes(Application.dataPath + "/SpaceTextures/space_stars.png", data);
        print(Application.dataPath + "/SpaceTextures/space_stars.png");


    }

    float CalculatePerlinFloat(int x, int y, int width, int height, float scale, float offsetX, float offsetY)
    {
        float xCoord = (float)x / width * scale + offsetX;
        float yCoord = (float)y / height * scale + offsetY;

        float noicePixel = Mathf.PerlinNoise(xCoord, yCoord);
        return noicePixel;
    }
}
