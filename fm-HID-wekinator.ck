Wekinator wek;
wek.clear();

1 => int groupNum;

dac.gain(0);

addGroup( [0.0, 0.0, 0.0], [0.0, 0.0], 20 );
addGroup( [0.5, 0.5, 0.5], [.2, .6], 20 );
addGroup( [1.0, 1, 1], [0.8, 0.9], 20 );

wek.train();

// new input
float x[];
// to hold predicted output
float y[2];

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

SinOsc m => SinOsc c => dac;
// step function, add to modulator output
Step step => c;

// carrier frequency
440 => step.next;
// modulator frequency
110 => m.freq;
// index of modulation
300 => m.gain;


Hid hi;
HidMsg msg;

// which mouse
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open mouse 0, exit on fail
if( !hi.openMouse( device ) ) me.exit();
<<< "mouse '" + hi.name() + "' ready", "" >>>;

// infinite event loop
while( true )
{
    // wait on HidIn as event
    hi => now;

    // messages received
    while( hi.recv( msg ) )
    {
        // mouse motion
        if( msg.isMouseMotion() )
        {
            //predict(msg.cursorX, msg.deltaY);
            <<< msg.cursorX, msg.cursorY>>>;
            // 2+ y[0]*10$int => m.freq;
            // 100 + y[1]*3000 => m.freq;
        }
    }
}