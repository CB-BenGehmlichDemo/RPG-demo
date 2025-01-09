
       dcl-pr listServiceProgramInformation extpgm('QBNLSPGM');
         qualifiedUserSpaceName char(20) const;
         formatName char(8) const;
         qualifiedServiceProgramName char(20) const;
         apiError char(32767) options(*varsize);
       end-pr;

