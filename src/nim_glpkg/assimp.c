#include <assimp/cimport.h>        // Plain-C interface
#include <assimp/mesh.h>
#include <assimp/scene.h>        // Output data structure
#include <assimp/postprocess.h>    // Post processing flags
#include <stdio.h>


const struct aiScene* import_file(const char* string, const struct aiScene* scene) {
  // Start the import on the given file with some example postprocessing
  // Usually - if speed is not the most important aspect for you - you'll t
  // probably to request more postprocessing than we do in this example.
  scene = aiImportFile( "/home/darshan/Documents/projects/nim_gl/res/test.obj",
    aiProcess_CalcTangentSpace       |
    aiProcess_Triangulate            |
    aiProcess_JoinIdenticalVertices  |
    aiProcess_SortByPType);

  // If the import failed, report it
  if(!scene) {
    printf("%s", aiGetErrorString());
    return 0;
  }

  printf("Size (from C)(aiscene):%d\n", (int)sizeof(struct aiScene));
  printf("from C(aiscene)%d\n", (int)sizeof(struct aiScene));
  printf("from C(ainode)%d\n", (int)sizeof(struct aiNode));
  printf("from C(aiMesh)%d\n", (int)sizeof(struct aiMesh));
  printf("from C(aiMaterial)%d\n", (int)sizeof(struct aiMaterial));
  printf("from C(aiAnimation)%d\n", (int)sizeof(struct aiAnimation));
  printf("from C(aiTexture)%d\n", (int)sizeof(struct aiTexture));
  printf("from C(aiLight)%d\n", (int)sizeof(struct aiLight));
  printf("from C(aiCamera)%d\n", (int)sizeof(struct aiCamera));
  printf("from C(aiMetadata)%d\n", (int)sizeof(struct aiMetadata));
  printf("from C(aiString)%d\n", (int)sizeof(struct aiString));
  printf("from C(aiSkeleton)%d\n", (int)sizeof(struct aiSkeleton));
  printf("from C(aiNodeAnim)%d\n", (int)sizeof(struct aiNodeAnim));
  printf("from C(aiMeshAnim)%d\n", (int)sizeof(struct aiMeshAnim));
  printf("from C(aiMeshMorphAnim)%d\n", (int)sizeof(struct aiMeshMorphAnim));
  printf("from C(aiFace)%d\n", (int)sizeof(struct aiFace));
  printf("from C(aiBone)%d\n", (int)sizeof(struct aiBone));
  printf("from C(aiVertexWeight)%d\n", (int)sizeof(struct aiVertexWeight));
  printf("from C(aiAABB)%d\n", (int)sizeof(struct aiAABB));
  printf("from C(aiAnimMesh)%d\n", (int)sizeof(struct aiAnimMesh));
  printf("from C(aiVector3D)%d\n", (int)sizeof(struct aiVector3D));
  printf("from C(aiColor4D)%d\n", (int)sizeof(struct aiColor4D));
  printf("from nim(cuint)%d\n", (int)sizeof(unsigned int));
  printf("from nim(cfloat)%d\n", (int)sizeof(float));
  printf("from nim(aiSkeleteonBone)%d\n", (int)sizeof(struct aiSkeletonBone));

  printf("hello world\n");
  printf("FUCKING LIGHTS: %d\n", scene->mNumLights);
  printf("FUCKING MESHEDS: %d\n", scene->mNumMeshes);
  // Now we can access the file's contents
//  DoTheSceneProcessing( scene);
  printf("mNumVerts: %d\n", scene->mMeshes[0]->mNumVertices);

  for(int i = 0; i < scene->mMeshes[0]->mNumFaces; i++)
  {
    for (int j = 0; j < scene->mMeshes[0]->mFaces[i].mNumIndices; j++)
    {
      printf("mIndices%d:%d\n", j,  scene->mMeshes[0]->mFaces[i].mIndices[j]);
    }
  }
  // We're done. Release all resources associated with this import
// aiReleaseImport(scene);
  return scene;
}

void release_file(const struct aiScene* scene)
{
  aiReleaseImport(scene);
}