func vnormal_fill*(): cstring =
    """
    #version 330 core
    layout (location = 0) in vec3 aPos;
    //layout (location = 1) in vec3 aColor;
    //out vec3 v_Color;
    uniform mat4 u_mvp;
    void main() 
    {
        gl_Position = u_mvp * vec4(aPos, 1.0);
        //v_Color = aColor;
    } 
    """
    
func fnormal_fill*(): cstring =
    """
    #version 330 core
    //in vec3 v_Color;
    out vec4 FragColor;
    void main()
    {
        FragColor = vec4(1.0, 1.0, 0.0, 1.0);
    }
    """
    