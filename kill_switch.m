function kill_switch(serPort)
    global port;    
    port = serPort;

	fprintf('KILLSWITCH ENGAGE\n');
    SetFwdVelAngVelCreate(port, 0, 0 );
    return;
end