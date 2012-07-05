/***********************************************************************
 
 Copyright (c) 2008, 2009, Memo Akten, www.memo.tv
 *** The Mega Super Awesome Visuals Company ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of MSA Visuals nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 * ***********************************************************************/ 

#import "ofAppiPhoneWindow.h"

#import <UIKit/UIKit.h>

#import "ofMain.h"
#import "ofxiOS_EAGLView.h"

// use for checking if stuff has been initialized
#define NOT_INITIALIZED			-1000000

static bool bAppCreated = false;

static ofAppiPhoneWindow *_instance = NULL;

ofAppiPhoneWindow* ofAppiPhoneWindow::getInstance() {
	return _instance;
}


/******** Constructor ************/

ofAppiPhoneWindow::ofAppiPhoneWindow() {
	ofLog(OF_LOG_VERBOSE, "ofAppiPhoneWindow::ofAppiPhoneWindow()");
	if(_instance == NULL) _instance = this;
	else ofLog(OF_LOG_ERROR, "Instanciating ofAppiPhoneWindow more than once! how come?");

	bEnableSetupScreen = true;
    
    orientation = OF_ORIENTATION_DEFAULT;
	
	resetDimensions();
	
	depthEnabled=false;
	antiAliasingEnabled=false;
	retinaEnabled=false;
}

/******** Initialization methods ************/

void ofAppiPhoneWindow::setupOpenGL(int w, int h, int screenMode) {
	ofLog(OF_LOG_VERBOSE, "ofAppiPhoneWindow::setupOpenGL()");
	
	windowMode = screenMode;	// use this as flag for displaying status bar or not

	ofDisableTextureEdgeHack();
	
	
	// w & h are ignored, currently Apple don't allow windows which aren't fullscreen
	// DO NOTHING ELSE, opengl will be setup by the app which creates an opengl view
}


void ofAppiPhoneWindow::initializeWindow() {
	ofLog(OF_LOG_VERBOSE, "ofAppiPhoneWindow::initializeWindow()");
	// DO NOTHING, window will be created when the app is launched
}


void  ofAppiPhoneWindow::runAppViaInfiniteLoop(ofBaseApp * appPtr) {
	ofLog(OF_LOG_VERBOSE, "ofAppiPhoneWindow::runAppViaInfiniteLoop()");
	
    if (bAppCreated) {                                          // app already created, only reset values.
        resetDimensions();          // new OF app created, it could be a different window and screen size, so reset.
    } else {                                                    // app not yet created, created it!
        startAppWithDelegate( "ofxiPhoneAppDelegate" );
    }
}

void ofAppiPhoneWindow::startAppWithDelegate(string appDelegateClassName) {
    if( bAppCreated )
        return;
    
    bAppCreated = true;
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    UIApplicationMain(nil, nil, nil, [[[NSString alloc] initWithCString: appDelegateClassName.c_str()] autorelease]);
    [pool release];
}

void ofAppiPhoneWindow::resetDimensions() {
	windowPos.set(NOT_INITIALIZED, NOT_INITIALIZED);
	windowSize.set(NOT_INITIALIZED, NOT_INITIALIZED);
	screenSize.set(NOT_INITIALIZED, NOT_INITIALIZED);
}

/******** Set Window properties ************/

void setWindowPosition(int x, int y) {
	// DO NOTHING, you're not really allowed to play with window for now
}

void setWindowShape(int w, int h) {
	// DO NOTHING, you're not really allowed to play with window for now
}



/******** Get Window/Screen properties ************/

// return cached pos, read if nessecary
ofPoint	ofAppiPhoneWindow::getWindowPosition() {
	if(windowPos.x == NOT_INITIALIZED) {
		CGRect frame = [[ofxiOS_EAGLView getInstance] frame];
		windowPos.set(frame.origin.x, frame.origin.y, 0);
	}
	return windowPos;
}


// return cached size, read if nessecary
ofPoint	ofAppiPhoneWindow::getWindowSize() {
	if(windowSize.x == NOT_INITIALIZED) {
        CGRect frame = [[ofxiOS_EAGLView getInstance] frame];
		windowSize.set(frame.size.width, frame.size.height, 0);

		if(retinaEnabled){
            UIScreen * currentScreen = [ofxiOS_EAGLView getInstance].window.screen;  // current screen is the screen that GLView is attached to.
            if(!currentScreen){                                             // if GLView is not attached, assume to be main device screen.
                currentScreen = [UIScreen mainScreen];
            }
			if ([currentScreen respondsToSelector:@selector(scale)]){
				windowSize *= [currentScreen scale];
            }
        }
	}

	return windowSize;
}


// return cached size, read if nessecary
ofPoint	ofAppiPhoneWindow::getScreenSize() {
	if(screenSize.x == NOT_INITIALIZED) {
        UIScreen * currentScreen = [ofxiOS_EAGLView getInstance].window.screen; // current screen is the screen that GLView is attached to.
        if(!currentScreen){                                                     // if GLView is not attached, assume to be main device screen.
            currentScreen = [UIScreen mainScreen];
        }
		CGSize s = [currentScreen bounds].size;
		screenSize.set(s.width, s.height, 0);
		
		if(retinaEnabled){
			if ([currentScreen respondsToSelector:@selector(scale)]){
				screenSize *= [currentScreen scale];
            }
        }
	}
	return screenSize;
}

int ofAppiPhoneWindow::getWidth(){
	if( orientation == OF_ORIENTATION_DEFAULT || orientation == OF_ORIENTATION_180 ){
		return (int)getWindowSize().x;
	}
	
	return (int)getWindowSize().y;
}

int ofAppiPhoneWindow::getHeight(){
	if( orientation == OF_ORIENTATION_DEFAULT || orientation == OF_ORIENTATION_180 ){
		return (int)getWindowSize().y;
	}
	
	return (int)getWindowSize().x;
}

int	ofAppiPhoneWindow::getWindowMode() {
	return windowMode;
}

float ofAppiPhoneWindow::getFrameRate() {
	return [[ofxiOS_EAGLView getInstance] getFrameRate];
}

/******** Other stuff ************/
void ofAppiPhoneWindow::setFrameRate(float targetRate) {
	[[ofxiOS_EAGLView getInstance] setAnimationFrameRate:targetRate];
}

int	ofAppiPhoneWindow::getFrameNum() {
	return [[ofxiOS_EAGLView getInstance] getFrameNum];
}

double ofAppiPhoneWindow::getLastFrameTime() {
	return [[ofxiOS_EAGLView getInstance] getLastFrameTime];
}

void ofAppiPhoneWindow::setWindowTitle(string title) {
}


void ofAppiPhoneWindow::setFullscreen(bool fullscreen) {
	[[UIApplication sharedApplication] setStatusBarHidden:fullscreen animated:YES];
	
	if(fullscreen) windowMode		= OF_FULLSCREEN;
	else windowMode					= OF_WINDOW;
}

void ofAppiPhoneWindow::toggleFullscreen() {
	if(windowMode == OF_FULLSCREEN) setFullscreen(false);
	else setFullscreen(true);
}


void ofAppiPhoneWindow::enableSetupScreen(){
	bEnableSetupScreen = true;
};

void ofAppiPhoneWindow::disableSetupScreen(){
	bEnableSetupScreen = false;
};

bool ofAppiPhoneWindow::isSetupScreenEnabled() {
    return bEnableSetupScreen;
}

void ofAppiPhoneWindow::setOrientation(ofOrientation orientation) {

	ofLog(OF_LOG_VERBOSE, "ofAppiPhoneWindow::setOrientation: " + ofToString(orientation));
	switch (orientation) {
		case OF_ORIENTATION_DEFAULT:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
			break;
		case OF_ORIENTATION_180:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortraitUpsideDown];
			break;
		case OF_ORIENTATION_90_RIGHT:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft];
			break;
		case OF_ORIENTATION_90_LEFT:
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];			
            break;
	}
	
	this->orientation = orientation;
	windowSize.x = NOT_INITIALIZED;
	screenSize.x = NOT_INITIALIZED;
	getScreenSize();
	getWindowSize();
}


ofOrientation ofAppiPhoneWindow::getOrientation() {
	return orientation;
}

void ofAppiPhoneWindow::rotateXY(float &x, float &y) {
	float savedX;
	switch(orientation) {
		case OF_ORIENTATION_180:
			x = getWidth() - x;
			y = getHeight() - y;
			break;
			
		case OF_ORIENTATION_90_LEFT:
			savedX = x;
			x = y;
			y = getHeight() - savedX;
			break;
			
		case OF_ORIENTATION_90_RIGHT:
			savedX = x;
			x = getWidth() - y;
			y = savedX;
			break;
			
		case OF_ORIENTATION_DEFAULT:
		default:
			break;
			
	}
}

void ofAppiPhoneWindow::enableRetinaSupport()
{
	retinaEnabled = true;
}

void ofAppiPhoneWindow::enableDepthBuffer()
{
	depthEnabled = true;
}

void ofAppiPhoneWindow::enableAntiAliasing(int samples)
{
	antiAliasingEnabled = true;
	antiAliasingSamples = samples;
}

bool ofAppiPhoneWindow::isDepthEnabled()
{
	return depthEnabled;
}

bool ofAppiPhoneWindow::isAntiAliasingEnabled()
{
	return antiAliasingEnabled;
}

int ofAppiPhoneWindow::getAntiAliasingSampleCount()
{
	return antiAliasingSamples;
}

bool ofAppiPhoneWindow::isRetinaSupported()
{
	return retinaEnabled;
}

void ofAppiPhoneWindow::timerLoop() {
    // all the timerLoop logic has been moved into [ofxiOS_EAGLView drawView]
}
