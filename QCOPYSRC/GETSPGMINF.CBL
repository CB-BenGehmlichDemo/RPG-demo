    
       dcl-pr getServiceProgramInformation extpgm('QBNRSPGM');
         receiver char(32767) options(*varsize);
         receiverLength int(10) const;
         formatName char(8) const;
         qualifiedServiceProgramName char(20) const;
         apiError char(32767) options(*varsize);
       end-pr;

