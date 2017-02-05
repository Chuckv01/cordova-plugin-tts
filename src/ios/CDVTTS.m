/*
 Cordova Text-to-Speech Plugin
 https://github.com/anagrath/cordova-plugin-tts
 
 originally by VILIC VANE
 https://github.com/vilic
 
 rewritten by Aditya Nagrath
 
 MIT License
 */

#import <Cordova/CDV.h>
#import "CDVTTS.h"

@implementation CDVTTS

- (void)pluginInitialize {
  synthesizer = [AVSpeechSynthesizer new];
  synthesizer.delegate = self;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance {
  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  
  if(callbackId != nil)
  {
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    callbackId = nil;
  }
  
  [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient
                                   withOptions: 0 error: nil];
  [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
}

- (void)speak:(CDVInvokedUrlCommand*)command {
  [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                   withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
  
  callbackId = command.callbackId;
  
  [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
  
  NSDictionary* options = [command.arguments objectAtIndex:0];
  
  NSString* text = [options objectForKey:@"text"];
  NSString* locale = [options objectForKey:@"locale"];
  double rate = [[options objectForKey:@"rate"] doubleValue];
  
  if (!locale || (id)locale == [NSNull null]) {
    locale = @"en-US";
  }
  
  if (!rate) {
    rate = 1.0;
  }
  [self.commandDelegate runInBackground:^{
    AVSpeechUtterance* utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:locale];
    // Rate expression adjusted manually for a closer match to other platform.
    utterance.rate = (AVSpeechUtteranceMinimumSpeechRate * 1.5 + AVSpeechUtteranceDefaultSpeechRate) / 2.5 * rate * rate;
    utterance.pitchMultiplier = 1.2;
    
    [synthesizer speakUtterance:utterance];
  }];
}

- (void)stop:(CDVInvokedUrlCommand*)command {
  [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)isSpeaking:(CDVInvokedUrlCommand*)command {
  NSString *callbackID = [command callbackId];
  BOOL isSpeaking = [synthesizer isSpeaking];
  CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsBool:isSpeaking];
  
  [self.commandDelegate sendPluginResult:result callbackId:callbackID];
  callbackID = nil;
}

- (void)clear:(CDVInvokedUrlCommand*)command {
  callbackId = nil;
}
@end