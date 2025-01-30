function gui_e
	% Comment out the next line, then uncomment the lines
	% related to your OS
	%error('You must edit this file first!');

	% Use this line for Windows
	% Edit 'COM4' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
	h.port=serialport('COM6',921600);

	% Use this line for Linux
	% Edit '/dev/ttyUSB1' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
	% (also use "chmod 777 /dev/ttyUSB*" as root to enable access)
%	h.port=serialport('/dev/ttyUSB1',921600);

	% Use this line for Mac OS X
	% Edit '/dev/tty.usbserial-210376B5B9DC1' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
%	h.port=serialport('/dev/tty.usbserial-210376B5B9DC1',921600);

	% Initialize UIControls
	h.closefig=0;
	h.fig=figure('Position',[300 300 175 225]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.led1=uicontrol('Style','text',...
		'String','1',...
		'Units','pixels',...
		'Position',[25 175 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led2=uicontrol('Style','text',...
		'String','2',...
		'Units','pixels',...
		'Position',[75 175 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led3=uicontrol('Style','text',...
		'String','3',...
		'Units','pixels',...
		'Position',[125 175 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led4=uicontrol('Style','text',...
		'String','4',...
		'Units','pixels',...
		'Position',[25 125 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led5=uicontrol('Style','text',...
		'String','5',...
		'Units','pixels',...
		'Position',[75 125 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led6=uicontrol('Style','text',...
		'String','6',...
		'Units','pixels',...
		'Position',[125 125 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led7=uicontrol('Style','text',...
		'String','7',...
		'Units','pixels',...
		'Position',[25 75 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led8=uicontrol('Style','text',...
		'String','8',...
		'Units','pixels',...
		'Position',[75 75 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.led9=uicontrol('Style','text',...
		'String','9',...
		'Units','pixels',...
		'Position',[125 75 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.leda=uicontrol('Style','text',...
		'String','*',...
		'Units','pixels',...
		'Position',[25 25 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.ledb=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[75 25 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');
	h.ledc=uicontrol('Style','text',...
		'String','#',...
		'Units','pixels',...
		'Position',[125 25 25 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'BackgroundColor','white');

	% Set units to normalized to make the window extensible
	set(h.led1,'Units','normalized');
	set(h.led1,'FontUnits','normalized');
	set(h.led2,'Units','normalized');
	set(h.led2,'FontUnits','normalized');
	set(h.led3,'Units','normalized');
	set(h.led3,'FontUnits','normalized');
	set(h.led4,'Units','normalized');
	set(h.led4,'FontUnits','normalized');
	set(h.led5,'Units','normalized');
	set(h.led5,'FontUnits','normalized');
	set(h.led6,'Units','normalized');
	set(h.led6,'FontUnits','normalized');
	set(h.led7,'Units','normalized');
	set(h.led7,'FontUnits','normalized');
	set(h.led8,'Units','normalized');
	set(h.led8,'FontUnits','normalized');
	set(h.led9,'Units','normalized');
	set(h.led9,'FontUnits','normalized');
	set(h.leda,'Units','normalized');
	set(h.leda,'FontUnits','normalized');
	set(h.ledb,'Units','normalized');
	set(h.ledb,'FontUnits','normalized');
	set(h.ledc,'Units','normalized');
	set(h.ledc,'FontUnits','normalized');

	% Main loop
	h.error='';
	while true
		% Check for a close figure request
		if (h.closefig==1)
			break;
		end

		% Send dummy data to FPGA
		write(h.port,0,'uint8');

		% Pause to prevent CPU saturation
		pause(0.01);

		% Read two bytes from FPGA
		leds=read(h.port,2,'uint8');
		if (length(leds)~=2)
			h.error='Timeout reading from FPGA board.';
			break;
		end

		% Check synchronization
		if (bitget(leds(1),8)~=1)||(bitget(leds(2),8)~=0)
			h.error='Out of sync error.';
			break;
		end

		if bitget(leds(2),5)
			set(h.led1,'BackgroundColor','black');
		else
			set(h.led1,'BackgroundColor','white');
		end
		if bitget(leds(2),4)
			set(h.led2,'BackgroundColor','black');
		else
			set(h.led2,'BackgroundColor','white');
		end
		if bitget(leds(2),3)
			set(h.led3,'BackgroundColor','black');
		else
			set(h.led3,'BackgroundColor','white');
		end
		if bitget(leds(2),2)
			set(h.led4,'BackgroundColor','black');
		else
			set(h.led4,'BackgroundColor','white');
		end
		if bitget(leds(2),1)
			set(h.led5,'BackgroundColor','black');
		else
			set(h.led5,'BackgroundColor','white');
		end
		if bitget(leds(1),7)
			set(h.led6,'BackgroundColor','black');
		else
			set(h.led6,'BackgroundColor','white');
		end
		if bitget(leds(1),6)
			set(h.led7,'BackgroundColor','black');
		else
			set(h.led7,'BackgroundColor','white');
		end
		if bitget(leds(1),5)
			set(h.led8,'BackgroundColor','black');
		else
			set(h.led8,'BackgroundColor','white');
		end
		if bitget(leds(1),4)
			set(h.led9,'BackgroundColor','black');
		else
			set(h.led9,'BackgroundColor','white');
		end
		if bitget(leds(1),3)
			set(h.leda,'BackgroundColor','black');
		else
			set(h.leda,'BackgroundColor','white');
		end
		if bitget(leds(1),2)
			set(h.ledb,'BackgroundColor','black');
		else
			set(h.ledb,'BackgroundColor','white');
		end
		if bitget(leds(1),1)
			set(h.ledc,'BackgroundColor','black');
		else
			set(h.ledc,'BackgroundColor','white');
		end

		% Update window
		drawnow;
	end

	% Clean up and exit
	clear h.port
	delete(h.fig);
	if (~isempty(h.error))
		error(h.error);
	end

	% Callbacks
	function closefig(~,~)
		h.closefig=1;
	end
end
