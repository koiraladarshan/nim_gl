func vnormal_fill*(): cstring =
    """
    #version 330 core
    layout (location = 0) in vec3 aPos;
    layout (location = 1) in vec3 aColor;
    layout (location = 2) in vec3 aNormal;

    out vec3 v_normal;
    out vec3 v_fragpos;
    out vec3 v_color;

    uniform mat4 u_mvp;

    void main() 
    {
        gl_Position = u_mvp * vec4(aPos, 1.0);
        v_fragpos = vec3(u_mvp * vec4(aPos, 1.0));
        v_normal = aNormal;
        v_color = aColor;
    } 
    """
    
func fnormal_fill*(): cstring =
    """
    #version 330 core
    in vec3 v_normal;
    in vec3 v_fragpos;
    in vec3 v_color;
    out vec4 FragColor;

    vec3 lightPos = vec3(-5, -5, -5);
    vec3 norm = normalize(v_normal);
    vec3 light_dir = normalize(lightPos - v_fragpos);

    void main()
    {
        float diff = max(dot(norm, light_dir), 0.0);
        vec3 diffuse = diff * vec3(1.0, 1.0, 1.0);
        vec3 result = diffuse * vec3(1.0, 1.0, 0.0);
        FragColor = vec4(result, 1.0);
    }
    """
    