#import "AppDelegate.h"


@interface AppDelegate ()
@property (nonatomic, strong) PAEAudioHost* host;
@property (nonatomic, strong) NSArray* channelStrips;
@property (nonatomic, strong) NSArray* filemnames;
@property (nonatomic) int nextVoice;
@end

@implementation AppDelegate

int grabs[4][6];
- (void)initialiseGrabs;
{
    for (int i = 0; i < 4; i++)
    {
        for (int e = 0; e < 6; e++) {
            grabs[i][e] = 0;
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.host = [PAEAudioHost audioHostWithNumOutputs:2];
    // initialise Grabs Array
    [self initialiseGrabs];
    
    // filenames for the audio files
    self.filemnames = @[@"guitar-E1.wav", @"guitar-A2.wav", @"guitar-D3.wav",
                        @"guitar-G3.wav", @"guitar-B3.wav", @"guitar-E4.wav"];
    
    // number of available channel strips to play the sounds
    const int numVoices = 8;
    
    NSMutableArray* channelStrips = [[NSMutableArray alloc] initWithCapacity:numVoices];
    
    
    // creat channel strip array
    for (int i = 0; i < numVoices; ++i)
    {
        PAEChannelStrip* channelStrip = [PAEChannelStrip channelStripWithNumChannels:2];
        [channelStrips addObject:channelStrip];
    }
    
    self.channelStrips = [NSArray arrayWithArray:channelStrips];
    
    // overall gain
    PAEAmplitude* amp = [PAEAmplitude amplitudeWithNumInputs:2];
    amp.input = [PAEMixer mixerWithSources:self.channelStrips];
    amp.level.input = [PAEConstant constantWithValue:1.0 / numVoices];
    
    // main mix
    self.host.mainMix = amp;
    
    [self.host start];
    
    return YES;
}

-(void)transpose:(int)fret ofString:(int)string withState:(BOOL)state;
{
    // Making sure that only valid array positions are being accessed
    if (fret < 0)
        fret = 0;
    if (fret > 3)
        fret = 3;
    if (string < 0)
        string = 0;
    if (string > 5)
        string = 5;
    
    // print statement helps with debugging.
    printf(" fret = %i on string = %i with state = %i\n", fret, string, state);
    // updates the grab array item that has just changed
    grabs[fret][string] = state;
    
    
 
}


-(void)play:(int)index velocity:(float)velocity;
{
    if (index >= 0 && index < self.filemnames.count)
    {
        PAEAudioFilePlayer* player = [PAEAudioFilePlayer audioFilePlayerNamed:self.filemnames[index]];
        player.loop = NO;
        
        int transpose = 1;          // initialising transpose variable
        
        for (int i = 0; i < 4; i++) {       // check for transpose state of the string
            if(grabs[i][index] == 1)        // that's played now and update transpose
            {                               // variable if necessary.
                transpose = i + 2;
            }
        }
        
        player.rate.input = [PAEConstant constantWithValue:pow(2.0, transpose / 12.0)];
        
        // gain based on the "velocity"
        PAEAmplitude* amp = [PAEAmplitude amplitudeWithNumInputs:player.numChannels];
        amp.input = player;
        amp.level.input = [PAEConstant constantWithValue:velocity];
        
        // choose a channel strip to play it
        PAEChannelStrip* channelStrip = self.channelStrips[self.nextVoice];
        channelStrip.input = amp;
        
        // increment to the next voice index for next time
        self.nextVoice++;
        
        // wrap back to zero if we run out of channel strips
        if (self.nextVoice == self.channelStrips.count)
            self.nextVoice = 0;
    }
}

@end
