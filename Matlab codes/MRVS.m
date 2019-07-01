classdef MRVS < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MobileRobotControlMenuUIFigure  matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxes4                         matlab.ui.control.UIAxes
        SearchButton                    matlab.ui.control.Button
        GoButton                        matlab.ui.control.Button
        MessageBoxTextAreaLabel         matlab.ui.control.Label
        MessageBoxTextArea              matlab.ui.control.TextArea
        DistanceTextAreaLabel           matlab.ui.control.Label
        DistanceTextArea                matlab.ui.control.TextArea
        ConnectButton                   matlab.ui.control.Button
        DisconnectButton                matlab.ui.control.Button
        Button                          matlab.ui.control.Button
    end

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        end

        % Button pushed function: ConnectButton
        function ConnectButtonPushed(app, event)
            %load('calibrationSession5.mat');
            global a;
            global r1;global r2;global l1;global l2;global m1;global m2;
            global m3; global m4; global dly; global trigPin; global echoPin;
            
            a= arduino('COM4');
            
            
            % Right-hand side motors:
            r1=2;
            r2=4;
            % Left-hand side motors:
            l1=7;
            l2=8;
            
            % Analog signal for motors speed:
            m1=10;
            m2=3;
            m3=6;
            m4=9;
            dly = 1500;
            
            % Ultrasonic code:
            trigPin = 11;    % Trigger
            echoPin = 12;    % Echo
            
            a.pinMode(r1, 'output');
            a.pinMode(r2, 'output');
            a.pinMode(l1, 'output');
            a.pinMode(l2, 'output');
            a.pinMode(m1, 'output');
            a.pinMode(m2, 'output');
            a.pinMode(m3, 'output');
            a.pinMode(m4, 'output');
            
            
            
            a.pinMode(trigPin, 'output');
            a.pinMode(echoPin, 'input');
            
            analogWrite(a,m1,255);
            analogWrite(a,m2,233);
            analogWrite(a,m3,230);
            analogWrite(a,m4,255);
            
            
            
        end

        % Callback function
        function DisconnectButtonPushed(app, event)
            delete(instrfind({'Port'},{'COM4'}))
            clear all
            
        end

        % Button pushed function: SearchButton
        function SearchButtonPushed(app, event)
            Radius1=0; Radius2=0; bool=0; i=0;
            global a; global cam1; global cam2;
            global r1;global r2;global l1;global l2;
            load('calibrationSession5.mat');
            cam1 = webcam(1);
            cam2 = webcam(3);
            
            sizeRadius1=0;
            sizeRadius2=0;
            %             cam1 = webcam(1);
            %             cam2 = webcam(3);
            %             cam1.Resolution = '1280x960';
            %             cam2.Resolution = '1280x960';
            
            
            while i<=18
                
                
                digitalWrite(a,r1,1);
                digitalWrite(a,r2,0);
                digitalWrite(a,l1,0);
                digitalWrite(a,l2,1);
                
                java.lang.Thread.sleep(250);
                
                digitalWrite(a,r1,0);
                digitalWrite(a,r2,0);
                digitalWrite(a,l1,0);
                digitalWrite(a,l2,0);
                java.lang.Thread.sleep(250);
                
                i=i+1;
                
                try
                    img = snapshot(cam1);
                    imwrite(img,'picLeft.jpg');
                    img2 = snapshot(cam2);
                    imwrite(img2,'picRight.jpg');
                    
                    java.lang.Thread.sleep(100);
                    
                catch
                    clear cam1; clear cam2
                    answer='Press it again lol';
                    app.MessageBoxTextArea.Value=answer;
                    break;
                    
                end %end try/catch
                
                testI =imread('picLeft.jpg');
                testII=imread('picRight.jpg');
                
                testI=imrotate(testI,90);
                testII=imrotate(testII,90);
                
                I1=rgb2gray(testI);
                I2=rgb2gray(testII);
                
                [I1,I2] = rectifyStereoImages(I1,I2,calibrationSession.CameraParameters);
                
                
                
                
                
                %finding circles:
                [Center1,Radius1]=imfindcircles(I1,[10 100],'ObjectPolarity',...
                    'dark', 'Sensitivity',0.8);
                
                [Center2,Radius2]=imfindcircles(I2,[10 100],'ObjectPolarity',...
                    'dark', 'Sensitivity',0.8);
                
                %processing
                sizeRadius1=size(Radius1);
                sizeRadius2=size(Radius2);
                
                if mean(Radius1) > 0 && mean(Radius2) > 0
                    bool=1;
                    break;
                end
                
            end %end while
            
            if bool ==1 %if there is one or more circles
                
                
                if sizeRadius1(1) == 1 && sizeRadius2(1) ==1
                    %there is one circle:
                    
                    %finding disparity:
                    disparityRange = [0 128]; % arbitrary number and divisable by 8, max = 128
                    disparityMap = disparity(I1,I2,'BlockSize', 15,'DisparityRange',disparityRange);
                    
                    answer='Circle Found!';
                    app.MessageBoxTextArea.Value=answer;
                    
                    %showing proper images:
                    %left
                    
                    imshow(testI, 'parent', app.UIAxes);
                    %                     h1 = viscircles(Center1,Radius1);
                    
                    %right
                    imshow(testII, 'parent', app.UIAxes2);
                    %                     h2 = viscircles(Center2,Radius2);
                    
                    %both
                    imshow(stereoAnaglyph(I1,I2), 'parent',app.UIAxes3)
                    
                    %disparity
                    imshow(disparityMap,disparityRange, 'parent', app.UIAxes4);
                    %                     colormap(gca,jet)
                    %                     colorbar
                    
                    %more processing:
                    theCenter=(Center1+Center2)/2;
                    x=floor(theCenter(1));
                    y=floor(theCenter(2));
                    
                    f=846;
                    b=9.6;
                    
                    distance=f*b/disparityMap(y,x);
                    
                    %showing messages:
                    distance=num2str(distance);
                    app.DistanceTextArea.Value=distance;
                    
                    
                    
                    %                 elseif sizeRadius1(1) > 1 && sizeRadius2(1) > 1
                    %                     %if there are multiple circles.
                    %                     answer='There are more than one Circle!';
                    %                     app.MessageBoxTextArea.Value=answer;
                end
                
                
            else
                %there is no circle
                answer='Cannot find the circle!';
                app.MessageBoxTextArea.Value=answer;
            end
        end

        % Button pushed function: GoButton
        function GoButtonPushed(app, event)
            myCode
        end

        % Button pushed function: Button
        function ButtonPushed(app, event)
            cam1 = webcam(1);
            cam2 = webcam(3);
            img = snapshot(cam1);
            imwrite(img,'picLeft.jpg');
            img2 = snapshot(cam2);
            imwrite(img2,'picRight.jpg');
            
            java.lang.Thread.sleep(100);
            imshow(img, 'parent', app.UIAxes);
            imshow(img2, 'parent', app.UIAxes2);
            
            
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MobileRobotControlMenuUIFigure
            app.MobileRobotControlMenuUIFigure = uifigure;
            app.MobileRobotControlMenuUIFigure.Color = [0.9373 0.9373 0.9373];
            app.MobileRobotControlMenuUIFigure.Position = [100 100 1201 552];
            app.MobileRobotControlMenuUIFigure.Name = 'Mobile Robot Control Menu';
            setAutoResize(app, app.MobileRobotControlMenuUIFigure, true)

            % Create UIAxes
            app.UIAxes = uiaxes(app.MobileRobotControlMenuUIFigure);
            title(app.UIAxes, 'Left Camera');
            app.UIAxes.Position = [31 168 279 347];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.MobileRobotControlMenuUIFigure);
            title(app.UIAxes2, 'Right Camera');
            app.UIAxes2.Position = [310 168 279 347];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.MobileRobotControlMenuUIFigure);
            title(app.UIAxes3, 'Both');
            app.UIAxes3.Position = [589 168 279 347];

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.MobileRobotControlMenuUIFigure);
            title(app.UIAxes4, 'Disparity');
            app.UIAxes4.Position = [868 168 279 347];

            % Create SearchButton
            app.SearchButton = uibutton(app.MobileRobotControlMenuUIFigure, 'push');
            app.SearchButton.ButtonPushedFcn = createCallbackFcn(app, @SearchButtonPushed, true);
            app.SearchButton.Position = [321 63 120 30];
            app.SearchButton.Text = 'Search';

            % Create GoButton
            app.GoButton = uibutton(app.MobileRobotControlMenuUIFigure, 'push');
            app.GoButton.ButtonPushedFcn = createCallbackFcn(app, @GoButtonPushed, true);
            app.GoButton.Position = [461 63 120 30];
            app.GoButton.Text = 'Go';

            % Create MessageBoxTextAreaLabel
            app.MessageBoxTextAreaLabel = uilabel(app.MobileRobotControlMenuUIFigure);
            app.MessageBoxTextAreaLabel.HorizontalAlignment = 'right';
            app.MessageBoxTextAreaLabel.Position = [721 138 79 15];
            app.MessageBoxTextAreaLabel.Text = 'Message Box';

            % Create MessageBoxTextArea
            app.MessageBoxTextArea = uitextarea(app.MobileRobotControlMenuUIFigure);
            app.MessageBoxTextArea.Position = [661 53 200 82];

            % Create DistanceTextAreaLabel
            app.DistanceTextAreaLabel = uilabel(app.MobileRobotControlMenuUIFigure);
            app.DistanceTextAreaLabel.HorizontalAlignment = 'right';
            app.DistanceTextAreaLabel.Position = [893 138 53 15];
            app.DistanceTextAreaLabel.Text = 'Distance';

            % Create DistanceTextArea
            app.DistanceTextArea = uitextarea(app.MobileRobotControlMenuUIFigure);
            app.DistanceTextArea.Position = [881 53 92 80];

            % Create ConnectButton
            app.ConnectButton = uibutton(app.MobileRobotControlMenuUIFigure, 'push');
            app.ConnectButton.ButtonPushedFcn = createCallbackFcn(app, @ConnectButtonPushed, true);
            app.ConnectButton.Position = [99 92 100 22];
            app.ConnectButton.Text = 'Connect';

            % Create DisconnectButton
            app.DisconnectButton = uibutton(app.MobileRobotControlMenuUIFigure, 'push');
            app.DisconnectButton.ButtonPushedFcn = createCallbackFcn(app, @DisconnectButtonPushed, true);
            app.DisconnectButton.Position = [99 53 100 22];
            app.DisconnectButton.Text = 'Disconnect';

            % Create Button
            app.Button = uibutton(app.MobileRobotControlMenuUIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Position = [400 117 100 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = MRVS()

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MobileRobotControlMenuUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MobileRobotControlMenuUIFigure)
        end
    end
end