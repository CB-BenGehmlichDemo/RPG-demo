
       dcl-pr getObjectDescription extpgm('QUSROBJD');
         receiver char(32767) options(*varsize);
         receiverLength int(10) const;
         formatName char(8) const;
         qualifiedObjectName char(20) const;
         objectType char(10) const;
         apiError char(32767) options(*nopass:*varsize);
         aspControl char(32767) options(*nopass:*varsize);
       end-pr;

