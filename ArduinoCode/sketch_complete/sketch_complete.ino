// Kamran Farid Research Project
#include <WiFiManager.h>
#include <HTTPClient.h>
#include <WiFiClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <ArduinoJson.h>
StaticJsonDocument<2000> ECG_ARR;
#include "MAX30105.h"

#include "heartRate.h"

MAX30105 particleSensor;


double avered = 0; double aveir = 0;
double sumirrms = 0;
double sumredrms = 0;
int i = 0;
int bpm_count = 0;
int Num = 100;//calculate SpO2 by this sampling interval

double ESpO2 = 95.0;//initial value of estimated SpO2
double FSpO2 = 0.7; //filter factor for estimated SpO2
double frate = 0.95; //low pass filter for IR/red LED value to eliminate AC component
#define TIMETOBOOT 3000 // wait for this time(msec) to output SpO2
#define SCALE 88.0 //adjust to display heart beat and SpO2 in the same scale
#define SAMPLING 5 //if you want to see heart beat more precisely , set SAMPLING to 1
#define FINGER_ON 30000 // if red signal is lower than this , it indicates your finger is not on the sensor
#define MINIMUM_SPO2 80.0

///////////////////////////////////////////////////////
// Recommended settings for the MAX30100, DO NOT CHANGE!!!!,  refer to the datasheet for further info
#define SAMPLING_RATE                       MAX30100_SAMPRATE_100HZ       // Max sample rate
#define IR_LED_CURRENT                      MAX30100_LED_CURR_50MA        // The LEDs currents must be set to a level that 
#define RED_LED_CURRENT                     MAX30100_LED_CURR_27_1MA      // avoids clipping and maximises the dynamic range
#define PULSE_WIDTH                         MAX30100_SPC_PW_1600US_16BITS // The pulse width of the LEDs driving determines
#define HIGHRES_MODE                        true                          // the resolution of the ADC

///////////////////////////////////////////////////////


const byte RATE_SIZE = 4; //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE]; //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0; //Time at which the last beat occurred

float beatsPerMinute;
int beatAvg;

#define USEFIFO




WiFiManager wm;

#define STASSID                 "test"        //WiFI Name
#define STAPSK                  "123456789"    //Password

//ECG///////////////////////////////////////////////////////////////////////////////////
#define SENSORPIN A0 // set A0 as SENSORPIN
char payload[10000];
char topic[150];
char str_sensor[10];
char str_millis[20];
double current_millis=0;
double current_millis_at_sensordata=0;
float ecg_val[100];

/////////////////////////////////////////////////////////////////////////////////////////
#define debug Serial //Uncomment this line if you're using an Uno or ESP

// Temp /////////////////////////////////////////////////////////////////////////////////
// GPIO where the DS18B20 is connected to
const int oneWireBus = 23;     

// Setup a oneWire instance to communicate with any OneWire devices
OneWire oneWire(oneWireBus);

// Pass our oneWire reference to Dallas Temperature sensor 
DallasTemperature TempSensor(&oneWire);
float temperatureF;
float temperatureC;
////////////////////////////////////////////////////////////////////////////////////////////

void WiFi_Connect()
{
  
    debug.println("Wifi Connect function ");
   // val = (Value *)malloc(MAX_VALUES*sizeof(Value));
    
    WiFi.setAutoConnect (true);
    WiFi.setAutoReconnect (true);
    WiFi.begin(STASSID, STAPSK);
    while (WiFi.status() != WL_CONNECTED) 
    {
        delay(500);
       // Serial.print(".");
    debug.println("Wifi Connected ");
    }
   
    
}

void init_oximeter()
{
 
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) //Use default I2C port, 400kHz speed
  {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }
  Serial.println("Place your index finger on the sensor with steady pressure.");

  //Setup to sense a nice looking saw tooth on the plotter
  byte ledBrightness = 0x7F; //Options: 0=Off to 255=50mA
  byte sampleAverage = 4; //Options: 1, 2, 4, 8, 16, 32
  byte ledMode = 2; //Options: 1 = Red only, 2 = Red + IR, 3 = Red + IR + Green
  //Options: 1 = IR only, 2 = Red + IR on MH-ET LIVE MAX30102 board
  int sampleRate = 200; //Options: 50, 100, 200, 400, 800, 1000, 1600, 3200
  int pulseWidth = 411; //Options: 69, 118, 215, 411
  int adcRange = 16384; //Options: 2048, 4096, 8192, 16384
  // Set up the wanted parameters
 particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange); //Configure sensor with these settings

  // particleSensor.setup(); //Configure sensor. Use 6.4mA for LED drive
  particleSensor.enableDIETEMPRDY();
  particleSensor.setPulseAmplitudeRed(0x0A); //Turn Red LED to low to indicate sensor is running
  particleSensor.setPulseAmplitudeGreen(0); //Turn off Green LED
}
void setup()
{
  Serial.begin(115200);
  Serial.println("Initializing...");
  init_oximeter();
  wm.setConfigPortalTimeout(180);
  wm.autoConnect("HealthMon"); 

  //ECG SENSOR SETUP /////////////////////////

  pinMode(SENSORPIN,INPUT);
  current_millis=millis();
  Serial.print("Current_millis = ");
  Serial.println(current_millis);
  /////////////////////////////////////////////
  // Temp /////////////////////////////////////
  
  // Start the DS18B20 sensor
  TempSensor.begin();
  /////////////////////////////////////////////
  

}

void loop()
{

  
  if(WiFi.status() != WL_CONNECTED)
  {
    //digitalWrite(ledPin, LOW);
    wm.autoConnect("HealthMon"); // password protected ap
    if(WiFi.status() == WL_CONNECTED) 
    {
     // client_connect();
    debug.println("Wifi Connected ");
    delay(500);
     
    }
  }

    init_oximeter();
        get_spo_bpm();
        get_ecg_temp();
        firebaseStorage();
  
}

void get_spo_bpm(){
  

while(bpm_count<500){
  long irValue = particleSensor.getIR();

  if (checkForBeat(irValue) == true)
  {
    //We sensed a beat!
    long delta = millis() - lastBeat;
    lastBeat = millis();

    beatsPerMinute = 60 / (delta / 1000.0);

    if (beatsPerMinute < 255 && beatsPerMinute > 20)
    {
      rates[rateSpot++] = (byte)beatsPerMinute; //Store this reading in the array
      rateSpot %= RATE_SIZE; //Wrap variable

      //Take average of readings
      beatAvg = 0;
      for (byte x = 0 ; x < RATE_SIZE ; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;
    }
  }

//  Serial.print("IR=");
//  Serial.print(irValue);
//  Serial.print(", BPM=");
//  Serial.print(beatsPerMinute);
//  Serial.print(", Avg BPM=");
//  Serial.print(beatAvg);

  if (irValue < 50000)
    Serial.print(" No finger?");






  uint32_t ir, red , green;
  double fred, fir;
  double SpO2 = 0; //raw SpO2 before low pass filtered

#ifdef USEFIFO
  particleSensor.check(); //Check the sensor, read up to 3 samples

  while (particleSensor.available()) {//do we have new data
#ifdef MAX30105
   red = particleSensor.getFIFORed(); //Sparkfun's MAX30105
    ir = particleSensor.getFIFOIR();  //Sparkfun's MAX30105
#else
    red = particleSensor.getFIFOIR(); //why getFOFOIR output Red data by MAX30102 on MH-ET LIVE breakout board
    ir = particleSensor.getFIFORed(); //why getFIFORed output IR data by MAX30102 on MH-ET LIVE breakout board
#endif

    
    
    i++;
    fred = (double)red;
    fir = (double)ir;
    avered = avered * frate + (double)red * (1.0 - frate);//average red level by low pass filter
    aveir = aveir * frate + (double)ir * (1.0 - frate); //average IR level by low pass filter
    sumredrms += (fred - avered) * (fred - avered); //square sum of alternate component of red level
    sumirrms += (fir - aveir) * (fir - aveir);//square sum of alternate component of IR level
    if ((i % SAMPLING) == 0) {//slow down graph plotting speed for arduino Serial plotter by thin out
      if ( millis() > TIMETOBOOT) {
        float ir_forGraph = (2.0 * fir - aveir) / aveir * SCALE;
        float red_forGraph = (2.0 * fred - avered) / avered * SCALE;
        //trancation for Serial plotter's autoscaling
        if ( ir_forGraph > 100.0) ir_forGraph = 100.0;
        if ( ir_forGraph < 80.0) ir_forGraph = 80.0;
        if ( red_forGraph > 100.0 ) red_forGraph = 100.0;
        if ( red_forGraph < 80.0 ) red_forGraph = 80.0;
        //        Serial.print(red); Serial.print(","); Serial.print(ir);Serial.print(".");
        if (ir < FINGER_ON) ESpO2 = MINIMUM_SPO2; //indicator for finger detached
        float temperature = particleSensor.readTemperatureF();
       // Blynk.run();
       // Blynk.virtualWrite(V4,ESpO2 );
      }
    }
    if ((i % Num) == 0) {
      double R = (sqrt(sumredrms) / avered) / (sqrt(sumirrms) / aveir);
      // Serial.println(R);
      SpO2 = -23.3 * (R - 0.4) + 100; //http://ww1.microchip.com/downloads/jp/AppNotes/00001525B_JP.pdf
      ESpO2 = FSpO2 * ESpO2 + (1.0 - FSpO2) * SpO2;//low pass filter
      //  Serial.print(SpO2);Serial.print(",");Serial.println(ESpO2);
      sumredrms = 0.0; sumirrms = 0.0; i = 0;
      break;
    }
    particleSensor.nextSample(); //We're finished with this sample so move to next sample
    //Serial.println(SpO2);
  }
#endif



//        Serial.print(" Oxygen % = ");
//       
//        Serial.println(ESpO2);

bpm_count++;
}
bpm_count=0;
  }






  
void get_ecg_temp(){


  int x=0;
  //ECG LOOP /////////////////////////////////////////////////
while(x<50){
    float sensor=analogRead(SENSORPIN);
    dtostrf(sensor,4,2,str_sensor);
    current_millis_at_sensordata=millis();
    dtostrf(current_millis_at_sensordata,10,0,str_millis);
    //float threshold = 800.0;
   // if(sensor<820){

      
//    Serial.print(" ECG  ");
//    Serial.println(sensor);
    //Serial.print(" Millis  ");
    //Serial.println(current_millis_at_sensordata);
   // }

   x++;
   

   ecg_val[x]=sensor;
   ECG_ARR[x]=sensor;
}
  ////////////////////////////////////////////////////////////
  // Temp ////////////////////////////////////////////////////
  
  TempSensor.requestTemperatures(); 
   temperatureC = TempSensor.getTempCByIndex(0);
   temperatureF = TempSensor.getTempFByIndex(0);

  
//  Serial.print(temperatureC);
//  Serial.println("ºC");
//  Serial.print(temperatureF);
//  Serial.println("ºF");
  ////////////////////////////////////////////////////////////
  
  
  }



void  firebaseStorage(){


  
  Serial.print(", Avg BPM=");
  Serial.print(beatAvg);
        Serial.print(" Oxygen % = ");
       
        Serial.println(ESpO2);
  Serial.print(temperatureC);
  Serial.println("ºC");
  Serial.print(temperatureF);
  Serial.println("ºF");
    Serial.println(" ECG  ");
    //Serial.println(ECG_ARR);


 if(WiFi.status()== WL_CONNECTED){
  
  String ecg_string;
  serializeJson(ECG_ARR, ecg_string);


      HTTPClient http;

        Serial.print("[HTTP] begin...\n");
        http.begin("https://us-central1-xamadukan.cloudfunctions.net/app/api/create/");
        http.addHeader("Content-Type", "application/json");
        StaticJsonDocument<2000> jsonBuffer;
    JsonObject root = jsonBuffer.to<JsonObject>();


//IDX75KM768
    root["patient"] = "IDX21NM788";
    root["bpm"] = beatAvg;
    root["spo"] = ESpO2;
    root["tempc"] = temperatureC;
    root["tempf"] = temperatureF;
    root["ecg"] = ecg_string;

String output;
  serializeJson(jsonBuffer, output);
      
        int httpCode = http.POST(output);
        
        if(httpCode > 0) {
            // HTTP header has been send and Server response header has been handled
            Serial.printf("[HTTP] GET... code: %d\n", httpCode);

            // file found at server
            if(httpCode == HTTP_CODE_OK) {
                String payload = http.getString();
                Serial.println(payload);
            }
        } else {
            Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
        }

        http.end();


        Serial.print("[HTTP] begin...\n");
        http.begin("https://us-central1-xamadukan.cloudfunctions.net/app/api/update/1");
        http.addHeader("Content-Type", "application/json");
        
      
        int httpCodex = http.PUT(output);
        
        if(httpCodex > 0) {
            // HTTP header has been send and Server response header has been handled
            Serial.printf("[HTTP] GET... code: %d\n", httpCodex);

            // file found at server
            if(httpCodex == HTTP_CODE_OK) {
                String payload = http.getString();
                Serial.println(payload);
            }
        } else {
            Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCodex).c_str());
        }

        http.end();
    }
    else {
      Serial.println("WiFi Disconnected");
    }



  
  delay(2000);
  
  }
