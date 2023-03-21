{.passl: "-lassimp".}
{.compile: "assimp.c".}

const libName = "libassimp.so"

const MAXLEN = 1024
const AI_MAX_NUMBER_OF_COLOR_SETS = 0x8
const AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x8
const HINTMAXTEXTURELEN = 9

#[
    ALL PFLAGS
]#



type 
    aiPostProcessSteps* = enum
        aiProcess_CalcTangentSpace = 0x1
        aiProcess_JoinIdenticalVertices = 0x2
        aiProcess_MakeLeftHanded = 0x4
        aiProcess_Triangulate = 0x8
        aiProcess_RemoveComponent = 0x10
        aiProcess_GenNormals = 0x20
        aiProcess_GenSmoothNormals = 0x40
        aiProcess_SplitLargeMeshes = 0x80
        aiProcess_PreTransformVertices = 0x100
        aiProcess_LimitBoneWeights = 0x200
        aiProcess_ValidateDataStructure = 0x400
        aiProcess_ImproveCacheLocality = 0x800
        aiProcess_RemoveRedundantMaterials = 0x1000,
        aiProcess_FixInfacingNormals = 0x2000,
        aiProcess_PopulateArmatureData = 0x4000,
        aiProcess_SortByPType = 0x8000,
        aiProcess_FindDegenerates = 0x10000,
        aiProcess_FindInvalidData = 0x20000,
        aiProcess_GenUVCoords = 0x40000,
        aiProcess_TransformUVCoords = 0x80000,
        aiProcess_FindInstances = 0x100000,
        aiProcess_OptimizeMeshes  = 0x200000,
        aiProcess_OptimizeGraph  = 0x400000,
        aiProcess_FlipUVs = 0x800000,
        aiProcess_FlipWindingOrder  = 0x1000000,
        aiProcess_SplitByBoneCount  = 0x2000000,
        aiProcess_Debone  = 0x4000000,
        aiProcess_GlobalScale = 0x8000000,
        aiProcess_EmbedTextures  = 0x10000000,
        aiProcess_ForceGenNormals = 0x20000000,
        aiProcess_DropNormals = 0x40000000,
        aiProcess_GenBoundingBoxes = 0x80000000


    aiString* = object
        length* : cuint
        data* : array[MAXLEN, cchar]
    
    aiMatrix4x4* = object
        a1*, a2*, a3*, a4* : cfloat
        b1*, b2*, b3*, b4* : cfloat
        c1*, c2*, c3*, c4* : cfloat
        d1*, d2*, d3*, d4* : cfloat
    
    aiVector2D* = object
        x*, y*: cfloat

    aiVector3D* = object
        x*, y*, z* : cfloat
    
    aiQuaternion* = object
        w*, x*, y*, z* : cfloat
    
    aiColor3D* = object
        r*, g*, b* : cfloat 

    aiColor4D* = object
        r*, g*, b*, a* : cfloat

    aiTexel* = object 
        b*, g*, r*, a* : uint8 #unsigned char

    aiAABB* = object
        mMin* : aiVector3D
        mMax* : aiVector3D
    
    aiMetadataType = enum
        AI_BOOL = 0
        AI_INT32 = 1
        AI_UINT64 = 2
        AI_FLOAT = 3
        AI_DOUBLE = 4
        AI_AISTRING = 5
        AI_AIVECTOR3D = 6
        AI_AIMETADATA = 7
        AI_META_MAX = 8
    
    aiMetadataEntry = object
        mType : aiMetadataType
        mData : pointer

    aiMetaData* = object
        mNumProperties* : cuint
        mKeys* : ptr aiString
        mValues* : ptr aiMetadataEntry
    
    aiNode* = object
        mName* : aiString
        mTransformation* : aiMatrix4x4
        mParent* : ptr aiNode
        nNumChildren* : cuint
        mChildren* : ptr ptr aiNode
        nNumMeshes* : cuint
        mMeshes* : ptr cuint
        mMetaData* : ptr aiMetaData
    
    aiFace* = object
        mNumIndices* : cuint
        mIndices* : ptr cuint

    aiVertexWeight* = object    
        mVertexId* : cuint
        mWeight* : cfloat

    aiBone* = object
        mName* : aiString
        mNumWeights* : cuint
        when not defined(ASSIMP_BUILD_NO_ARMATUREPOPULATE_PROCESS):
            mArmature* : ptr aiNode
            mNode* : ptr aiNode
        mWeights* : aiVertexWeight
        mOffsetMatrix* : aiMatrix4x4
        
    aiAnimMesh* = object
        mName* : aiString
        mVertices* : ptr aiVector3D
        mNormals* : ptr aiVector3D
        mTangents* : ptr aiVector3D
        mBitangents* : ptr aiVector3D
        mColors* : array[AI_MAX_NUMBER_OF_COLOR_SETS, ptr aiColor4D]
        mTextureCoords* : array[AI_MAX_NUMBER_OF_TEXTURECOORDS, ptr aiVector3D]
        mNumVertices* : cuint
        mWeight* : cfloat

    aiPropertyTypeInfo* = enum
        aiPTI_Float = 0x1
        aiPTI_Double = 0x2
        aiPTI_String = 0x3
        aiPTI_Integer = 0x4
        aiPTI_Buffer = 0x5
    
    aiMaterialProperty* = object
        mKey* : aiString
        mSemantic* : cuint
        mIndex* : cuint
        mDataLength* : cuint
        mType*: aiPropertyTypeInfo
        mData* : cstring

    aiMaterial* = object
        mProperties* : ptr ptr aiMaterialProperty
        mNumProperties* : cuint
        mNumAllocated* : cuint
    
    aiVectorKey* = object
        mTime* : cdouble
        mValue* : aiVector3D

    aiQuatKey* = object
        mTime* : cdouble
        mValue* : aiQuaternion

    aiAnimBehaviour* = enum
        aiAnimBehaviour_DEFAULT = 0x0
        aiAnimBehaviour_CONSTANT = 0x1
        aiAnimBehaviour_LINEAR = 0x2
        aiAnimBehaviour_REPEAT = 0x3

    aiNodeAnim* = object
        mNodeName* : aiString
        mNumPositionKeys* : cuint
        mPositionKeys* : ptr aiVectorKey
        mNumRotationKeys* : cuint
        mRotationKeys* : ptr aiQuatKey
        mNumScalingKeys* : cuint
        mScalingKeys* : ptr aiVectorKey
        mPreState* : aiAnimBehaviour
        mPostState* : aiAnimBehaviour


    aiMeshKey* = object
        mTime* : cdouble
        mValue* : cuint

    aiMeshAnim* = object
        mName* : aiString
        mNumKeys* : cuint
        mKeys* : ptr aiMeshKey
    
    aiMeshMorphKey* = object
        mTime* : cdouble
        mValues* : ptr cuint
        mWeights* : ptr cdouble
        mNumValuesAndWeights* : cuint

    aiMeshMorphAnim* = object
        mName* : aiString 
        mNumKeys* : cuint
        mKeys* : ptr aiMeshMorphKey

    aiAnimation* = object
        mName* : aiString
        mDuration* : cdouble
        mTicksPerSecond* : cdouble
        mNumChannels* : cuint
        mChannels* : ptr ptr aiNodeAnim
        mNumMeshChannels* : cuint
        mMeshChannels* : ptr ptr aiMeshAnim
        mNumMorphMeshChannels* : cuint
        mMorphMeshChannels* : ptr ptr aiMeshMorphAnim

    aiTexture* = object
        mWidth* : cuint
        mHeight* : cuint
        achFormatHint* : array[HINTMAXTEXTURELEN, cchar]
        pcData* : ptr aiTexel
        mFilename* : aiString

    aiMesh* = object
        mPrimitiveTypes* : cuint
        mNumVertices*: cuint
        mNumFaces* : cuint
        mVertices* : ptr aiVector3D
        mNormals* : ptr aiVector3D
        mTangents* : ptr aiVector3D
        mBitangents* : ptr aiVector3D
        mColors* : array[AI_MAX_NUMBER_OF_COLOR_SETS, ptr aiColor4D]
        mTextureCoords* :  array[AI_MAX_NUMBER_OF_TEXTURECOORDS, ptr aiVector3D]
        mNumUVComponents* : array[AI_MAX_NUMBER_OF_TEXTURECOORDS, cuint]
        mFaces* : ptr aiFace
        mNumBones* : cuint
        mBones* : ptr ptr aiBone
        mMaterialIndex* : cuint
        mName* : aiString
        mNumAnimMeshes* : cuint
        mAnimMeshes* : ptr ptr aiAnimMesh
        mMethod* : cuint
        mAABB* : aiAABB
        mTextureCoordsNames* : ptr ptr aiString

    aiLightSourceType* = enum
        aiLightSource_UNDEFINED = 0x0
        aiLightSource_DIRECTIONAL = 0x1
        aiLightSource_POINT = 0x2
        aiLightSource_SPOT = 0x3
        aiLightSource_AMBIENT = 0x4
        aiLightSource_AREA = 0x5

    aiLight* = object
        mName* : aiString
        mType* : aiLightSourceType
        mPosition* : aiVector3D
        mDirection* : aiVector3D
        mUp* : aiVector3D
        mAttenuationConstant* : cfloat
        mAttenuationLinear* : cfloat
        mAttenuationQuadratic* : cfloat
        mColorDiffuse* : aiColor3D
        mColorSpecular* : aiColor3D
        mColorAmbient* : aiColor3D
        mAngleInnerCone* : cfloat
        mAngleOuterCone* : cfloat
        mSize* : aiVector2D

    aiCamera* = object
        mName* : aiString
        mPosition* : aiVector3D
        mUp* : aiVector3D
        mLookAt* : aiVector3D
        mHorizontalFOV* : cfloat
        mClipPlaneNear* : cfloat
        mClipPlaneFar* : cfloat
        mAspect* : cfloat
        mOrthographicWidth* : cfloat
    
    aiSkeletonBone* = object
        mParent* : cint
        when not defined(ASSIMP_BUILD_NO_ARMATUREPOPULATE_PROCESS):
            mArmature*: ptr aiNode
            mNode* : ptr aiNode
        mNumnWeights : cuint
        mMeshId* : ptr aiMesh        
        mWeights* : ptr aiVertexWeight
        mOffsetMatrix* : aiMatrix4x4
        mLocalMatrix* : aiMatrix4x4

    aiSkeleton* = object
        mName* : aiString
        mNumBones* : cuint
        mBones* : ptr ptr aiSkeletonBone

type
  aiScene* = object
    mFlags*: cuint
    mRootNode*: ptr aiNode
    mNumMeshes*: cuint
    mMeshes*: ptr ptr aiMesh
    mNumMaterials*: cuint
    mMaterials*: ptr ptr aiMaterial
    mNumAnimations*: cuint
    mAnimations*: ptr ptr aiAnimation
    mNumTextures*: cuint
    mTextures*: ptr ptr aiTexture
    mNumLights*: cuint
    mLights*: ptr ptr aiLight
    mNumCameras*: cuint
    mCameras*: ptr ptr aiCamera
    mMetaData*: ptr aiMetadata
    mName*: aiString
    mNumSkeletons*: cuint
    mSkeletons*: ptr ptr aiSkeleton




proc aiImportFile*(pFile: cstring, pFlags: cuint) : ptr aiScene {.importc, dynLib:libName.}

proc import_file*(path: cstring, scene:  ptr aiScene) : cint {.importc.}

# proc import_file*(file : cstring) : ptr aiScene =
#     var scene : ptr aiScene
#     do_the_import_thing(file, scene)
#     echo scene.mNumLights
#     echo scene.mNumMeshes
#     result = scene