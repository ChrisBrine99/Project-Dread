varying vec4 v_vColour;

void main(){
    gl_FragColor = vec4(vec3(0.0), v_vColour.r);
}
