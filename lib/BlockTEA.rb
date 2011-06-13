module BlockTEA
	
	#
	# encrypt: Use Corrected Block TEA to encrypt plaintext using password
	# Return encrypted text as string
	#
	def encrypt(plaintext, password)
		if plaintext.length == 0
			return('')  # nothing to encrypt
		end
		
		# 'escape' plaintext so chars outside ISO-8859-1 work in single-byte packing, but  
		# keep spaces as spaces (not '%20') so encrypted text doesn't grow too long, and 
		# convert result to longs
#		v = strToLongs(escape(plaintext).gsub(/%20/,' '))
		v = strToLongs(plaintext)
		if v.length == 1
			v[1] = 0  # algorithm doesn't work for n<2 so fudge by adding nulls
		end
		k = strToLongs(password.ljust(16).slice(0,16))  # simply convert first 16 chars of password as key
		n = v.length
	
		z = v[n-1]
		y = v[0]
		delta = 0x9E3779B9
		#mx, e
		sum = 0
	
		(6 + 52.0/n).floor.downto(1) { |q|  # 6 + 52/n operations gives between 6 & 32 mixes on each word
			sum = (sum + delta) & 0xffffffff
			e = sum>>2 & 3
			for p in (0...n-1)
				y = v[p+1]
				mx = ((z>>5 ^ ((y<<2)&0xffffffff)) + (y>>3 ^ ((z<<4)&0xffffffff)) ^ (sum^y) + (k[p&3 ^ e] ^ z)) & 0xffffffff
				v[p] = (v[p] + mx) & 0xffffffff
				z = v[p]
			end
			y = v[0]
			mx = ((z>>5 ^ ((y<<2)&0xffffffff)) + (y>>3 ^ ((z<<4)&0xffffffff)) ^ (sum^y) + (k[(n-1)&3 ^ e] ^ z)) & 0xffffffff
			v[n-1] = (v[n-1] + mx) & 0xffffffff
			z = v[n-1]
		}
	
		ciphertext = longsToStr(v)
	
		return ciphertext.unpack('a*').pack('m').delete("\n") # base64 encode it without newlines
	end
	
	#
	# decrypt: Use Corrected Block TEA to decrypt ciphertext using password
	#
	def decrypt(ciphertext, password)
		if ciphertext.length == 0
			return('')
		end
		
		v = strToLongs(ciphertext.unpack('m').pack("a*"))	# base64 decode and convert to array of 'longs'
		k = strToLongs(password.ljust(16).slice(0,16))
		n = v.length
	
		z = v[n-1]
		y = v[0]
		delta = 0x9E3779B9
		#mx, e
		q = (6 + 52.0/n).floor
		sum = q*delta
		
		while (sum > 0)
			e = sum>>2 & 3
			(n-1).downto(1) { |p|
				z = v[p-1]
				mx = ((z>>5 ^ ((y<<2)&0xffffffff)) + (y>>3 ^ ((z<<4)&0xffffffff)) ^ (sum^y) + (k[p&3 ^ e] ^ z)) & 0xffffffff
				v[p] = (v[p] - mx) & 0xffffffff
				y = v[p]
			}
			z = v[n-1]
			mx = ((z>>5 ^ ((y<<2)&0xffffffff)) + (y>>3 ^ ((z<<4)&0xffffffff)) ^ (sum^y) + (k[0 ^ e] ^ z)) & 0xffffffff
			v[0] = (v[0] - mx) & 0xffffffff
			y = v[0]
			sum -= delta
		end
	
		plaintext = longsToStr(v)
	
		# strip trailing null chars resulting from filling 4-char blocks:
		plaintext = plaintext.gsub(/\0+$/,'')
	
		return plaintext
	end
	
	
	# supporting functions
	
	def strToLongs(s)
		s << [0,0,0].pack('c*') # Pad with at most three nulls
		return s.unpack('L*')
	end
	
	def longsToStr(l)   # convert array of longs back to string
		l.pack('L*')
	end
	
	module_function :encrypt, :decrypt, :strToLongs, :longsToStr
end
