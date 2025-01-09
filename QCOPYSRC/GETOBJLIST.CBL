
       dcl-pr getObjectList extpgm('QUSLOBJ');
         qualifiedUserSpaceName char(20) const;
         formatName char(8) const;
         qualifiedObjectName char(20) const;
         objectType char(10) const;
         apiError char(32767) options(*nopass:*varsize);
         authorityControl char(32767) options(*nopass:*varsize);
         selectionControl char(32767) options(*nopass:*varsize);
         aspControl char(32767) options(*nopass:*varsize);
       end-pr;

