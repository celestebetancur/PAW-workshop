// Feature extraction
adc => FFT fft =^ Centroid cen =^ FeatureCollector fc => blackhole;

fc.upchuck();
fc.fvals().size() => int NUM_DIMENSIONS;

// set FFT size
1024 => fft.size;
// set window type and size
Windowing.hann(fft.size()) => fft.window;
// our hop size (how often to perform analysis)
(fft.size()/2)::samp => dur HOP;

function void featureExtract(){

    while(true){

        fc.upchuck();

        for( int d; d < NUM_DIMENSIONS; d++ )
            {
                <<< fc.fval(d)>>>;
            }
        HOP => now;
    }
}
//-----------------------------------------------------------

// Operator overload
public int[] @operator !( int triggers[] )
{ 
    int toReturn[0];
    for(int t : triggers){
        if(t) toReturn << 0;
        else {toReturn << 1;}
    }
    return toReturn; 
}

public int[] @operator <<( int one[], int two[] )
{ 
    int toReturn[0];
    for(int i : one){
        toReturn << i;
    }
    for(int i : two){
        toReturn << i;
    }
    return toReturn; 
}
//----------------------------------------------------------

//chuGL 
// GG.fullscreen();

GG.scene() @=> GScene @ scene;

PlaneGeometry planeGeo;
planeGeo.set(16,9,100,100);

ShaderMaterial shaderMat;
GMesh mesh;

mesh.set( planeGeo, shaderMat );
mesh --> scene;

ShaderTools st;
global ShaderType ShaderCode;

st.osc(100,0.1,0.5) 
    -> st.modulateKaleid(st.osc(2,0.2,1))
     -> st.kaleid(4)
    -> st.mask(st.shape(4) -> st.invert() -> st.scale(2.9))
    -> st.add(st.osc() -> st.kaleid())
    @=> ShaderCode;

GPlane plane[48];
GMesh ggens[0];

for(auto p: plane){
    p --> scene;
    ggens << p;
}

for(int i; i < 6; i++){
    for(int j; j < 8; j++){
        1.1 * i - 2.75 => ggens[(i*8)+j].posY;
        1.1 * j - 4 => ggens[(i*8)+j].posX;
    }
}

GG.camera() --> scene;
GG.camera().posZ( 10 );
//-----------------------------------------------------------
//chAI mixed with some chuGL
1::minute/130/2 => dur T;

SndBuf bd => dac;
SndBuf hh => dac;
SndBuf oh => dac;
SndBuf cb => dac;
SndBuf p1 => dac;
SndBuf bass => dac;

0.3 => bass.gain;
dac.gain(0.5);

me.dir() + "/samples/000_BD.wav" => bd.read;
me.dir() + "/samples/000_hh3closedhh.wav" => hh.read;
me.dir() + "/samples/OH00.WAV" => oh.read;
me.dir() + "/samples/001_CB.wav" => cb.read;
me.dir() + "/samples/005_P1.wav" => p1.read;
me.dir() + "/samples/000_01.wav" => bass.read;

-1 => bd.pos => hh.pos => oh.pos => cb.pos => p1.pos => bass.pos;

HMM hmmBD, hmmHH, hmmOH, hmmBass;

8 => int size;

int observationsbd[size];
int observationshh[size];
int observationsoh[size];
int observationsbass[size];

[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1] @=> int kick[];
hmmBD.train(2,8,kick);
hmmHH.train(2,2,[1,1,1,1,1,0,1,1]);
hmmOH.train(2,2,!kick);
hmmBass.train(2,2,[1,1,0,1,1,1,1,1,1,0,1,0,1,1,1,1,0,1,0,1]);

int fullInfo[48];

fun void update()
{
    [0,0,0,0,1,0,0,0] << [1,0,0,1,0,0,0,0] << observationsbd << observationshh << observationsoh << observationsbass @=> fullInfo;
    for(int i; i < 48; i++){
        if(fullInfo[i]) @(1,1,1) => ggens[i].mat().color;
        else {@(0.1,0.1,0.1) => ggens[i].mat().color;}
    }
    GG.camera().lookAt( GG.scene().pos() );
}

function void player(HMM @ hmm, SndBuf @ buf, dur T, int obs[]){
    while(true){

        hmm.generate( size, obs );

        for ( int i: obs){
            if(i){
                0 => buf.pos;
                T => now;
            } else{
                T => now;
            }
        }
    }
}

function void fixedplayer(SndBuf @ buf, dur T, int trig[]){
    while(true){
        for ( int i: trig){
            if(i){
                0 => buf.pos;
                T => now;
            } else{
                T => now;
            }
        }
    }
}

spork~fixedplayer(cb,T,[0,0,0,0,1,0,0,0]);
spork~fixedplayer(p1,T/2,[1,0,0,1,0,0,0,0]);
spork~player(hmmBD,bd,T,observationsbd);
spork~player(hmmHH,hh,T/2,observationshh);
spork~player(hmmOH,oh,T,observationsoh);
spork~player(hmmBass,bass,T,observationsbass);

while( true )
{
    update();
    shaderMat.uniformFloat("u_Time", now/second);
    //Update shader graph
    shaderMat.fragString(st.shader(ShaderCode));
    GG.nextFrame() => now;
}
