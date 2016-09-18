/* Booting/Quitting/Rebooting the Server */
s = Server.local.boot;
s = Server.local.reboot;
s.quit;

/* Show the currently active nodes */

s.plotTree;

/* Show Input/Output Meters*/
s.meter; //or use Cmd-M
s.meter(2, 8); //Show 2 input and 8 output channels

/* Querying the server */

Server.local.outputBus;     //Post the hardware output bus numbers
Server.local.inputBus;       //Post the hardware input bus numbers

ServerOptions.devices;          //list all the input and output devices on the (local) server
ServerOptions.inDevices;       //list input devices only
ServerOptions.outDevices;     //list output devices only

/* Choosing and configuring your audio device, etc */

o = Server.local.options; //store the options in a variable (saves typing)

o.memSize; // default is 8192, but you can change this, then reboot server

o.blockSize; //default is 64 samples per control period

o.numBuffers; // default is 1024

o.device; //show current output device (will be nil until you set it)
o.device = "EDIROL FA-66 (0727)"; //set current output device
o.device = "Built-in Output";

o.outDevice; //might be different from your inDevice
o.inDevice;

o.hardwareBufferSize; //defaults to 'nil' which lets your hardware determine this
/* Note that you can change the above, but not all sizes are valid for your audio hardware */

o.sampleRate; //show current sample rate (defaults to 'nil', so uses current hardware settings)
o.sampleRate = 96000;
o.sampleRate = 44100;

o.numInputBusChannels;   //you can also set the number here
o.numOutputBusChannels;   //you can also set the number here
o.numOutputBusChannels = 8;  //need to reboot the server after setting
o.numOutputBusChannels = 2;

o.numAudioBusChannels; //default is 128, most are not connected to hardware
o.numControlBusChannels; //default is 4096, none connected to hardware

b = Bus.audio(s, 1); //this will allocate the first available audio bus that is not a hardware I/O bus.
b.index; //returns the index of bus b
b.free; //frees bus b




