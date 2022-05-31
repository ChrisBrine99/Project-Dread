varying vec4 v_vColour;

void main(){ // Simply turns the fragment being drawn to a black pixel of varying transparency.
    gl_FragColor = vec4(vec3(0.0), v_vColour.r);
}
