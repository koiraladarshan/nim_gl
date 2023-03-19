func vnormal_fill*(): cstring =
    """
    #version 330 core
    layout (location = 0) in vec3 aPos;
    layout (location = 1) in vec3 aColor;
    out vec3 v_Color;
    void main() 
    {
        gl_Position = vec4(aPos, 1.0);
        v_Color = aColor;
    } 
    """
    
func fnormal_fill*(): cstring =
    """
    #version 330 core
    in vec3 v_Color;
    out vec4 FragColor;
    void main()
    {
        FragColor = vec4(v_Color, 1.0);
    }
    """
    