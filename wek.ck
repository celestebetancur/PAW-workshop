Wekinator wek;
wek.clear();

1 => int groupNum;

addGroup( [0.0, 0.0, 0.0], [0.0, 0.0], 20 );
addGroup( [0.5, 0.5, 0.5], [.2, .6], 20 );
addGroup( [1.0, 1, 1], [0.8, 0.9], 20 );

wek.train();

// new input
float x[];
// to hold predicted output
float y[2];

repeat( 20 )
{
    // generate random input
    [Math.random2f(0,1), Math.random2f(0,1), Math.random2f(0,1)] @=> x;
    // predict and print
    predict( x, y );
}

// add a group of training observations
fun void addGroup( float inputs[], float outputs[], int N )
{
    repeat( N )
    {
        wek.input( inputs ); wek.output( outputs );
        wek.add();
    }
}

// predict and print
fun void predict( float inputs[], float outputs[] )
{
    // predict output based on input; 3 inputs -> 2 outputs
    wek.predict(inputs, outputs);
    // print
    cherr <= "(" <= inputs[0] <= ","<= inputs[1] <= ","<= inputs[2] <= ") -> ("
          <= outputs[0] <= ", " <= outputs[1] <= ")" <= IO.newline();
}