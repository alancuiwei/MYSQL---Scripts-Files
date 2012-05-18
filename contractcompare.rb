#encoding:utf-8
require 'rubygems'
require "mysql"
require 'date'

now=DateTime.now.to_s
now=now.split('+')[0].gsub(/T/,' ')

dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
sth=dbh.prepare("select * from todayinfo_t ") 
sth.execute 
file = File.new("contract/data.csv", "w+")
while row=sth.fetch do 
   file.puts row 
end 
file.close()

f=open('contract/data.csv')             
f=f.readlines
s=f.length
i=0	   
while(i<s)                         
 while(not f[i]=~/[a-zA-Z\d]+/)
      u=i
      while(u<s)
	   f[u]=f[u+1] 
	   u += 1
	   end
  s -= 1
   end	
   i += 1 
end
file = File.new("contract/data.txt", "w+")
i=0	   
while(i<s)       
    if(not f[i]=~/[a-zA-Z]{1,2}\d+/)                  
    file.puts sprintf("%1.2f", f[i])
	else
	file.puts f[i]
	end
   i += 1 
end
file.close()

f=open('../tongtianshun/app/assets/images/contract.xml')             
f=f.readlines
s=f.length
i=0	   
while(i<s)                         
   f[i]=f[i].gsub(/<(\w+)>/,'')
   f[i]=f[i].gsub(/<.+>/,'')
   i += 1 
end
file = File.new("contract/contract.txt", "w+")
i=0	   
while(i<s)                         
 if(f[i][0]=~/[a-zA-Z\d]/)
    file.puts f[i]
   end	  
   i += 1 
end
file.close()

f=open('contract/contract.txt')             
f=f.readlines
s=f.length
g=open('contract/data.txt')             
g=g.readlines
t=g.length
file = File.new("contract/comparison.txt", "w+")
i=0
while(i<t)
    if(g[i]=~/[a-zA-Z]{1,2}\d+/)
	    j=0
		a=0
        while(j<s)
		    if(g[i][0,1]=='b')
		      break
		    end
            if(g[i]==f[j])
			a=1
			    if(g[i+1].to_f!=f[j+1].to_f && g[i+2].to_f!=f[j+2].to_f)
	              file.puts g[i].gsub(/\n/,'')+','+g[i+1].gsub(/\n/,'')+','+f[j+1].gsub(/\n/,'')+',NOK,'+g[i+2].gsub(/\n/,'')+','+f[j+2].gsub(/\n/,'')+',NOK'
			    elsif(g[i+1].to_f==f[j+1].to_f && g[i+2].to_f!=f[j+2].to_f)
				  file.puts g[i].gsub(/\n/,'')+','+g[i+1].gsub(/\n/,'')+','+f[j+1].gsub(/\n/,'')+',OK,'+g[i+2].gsub(/\n/,'')+','+f[j+2].gsub(/\n/,'')+',NOK'
				elsif(g[i+1].to_f!=f[j+1].to_f && g[i+2].to_f==f[j+2].to_f)
				  file.puts g[i].gsub(/\n/,'')+','+g[i+1].gsub(/\n/,'')+','+f[j+1].gsub(/\n/,'')+',NOK,'+g[i+2].gsub(/\n/,'')+','+f[j+2].gsub(/\n/,'')+',OK'
				else
				  file.puts g[i].gsub(/\n/,'')+','+g[i+1].gsub(/\n/,'')+','+f[j+1].gsub(/\n/,'')+',OK,'+g[i+2].gsub(/\n/,'')+','+f[j+2].gsub(/\n/,'')+',OK'
				end
				break			    
	        end 
         			
        j+=1
        end		
		if(a==0 && g[i][0,1]!='b')
			file.puts g[i].gsub(/\n/,'')+','+g[i+1].gsub(/\n/,'')+',0,NOK,'+g[i+2].gsub(/\n/,'')+',0,NOK'
		end
	end
i+=1
end
file.close()

g=open('contract/comparison.txt')             
g=g.readlines
s=g.length
i=0
while(i<s) 
       g[i]='<tr><td>'+g[i].gsub(/,/,'</td><td>')+'</td></tr>'
       g[i]=g[i].gsub(/<td>NOK/,'<td bgcolor=darkblue>NOK')	   
       i += 1 
end
s=s+9 
g[s-9]='</table>'
i=s-1
while(i>0) 
    g[i] =g[i-8]	
       i -= 1 
end
g[0]='<style>'
g[1]='.rttableformat {margin-top:5px;padding:5px;border-collapse:collapse;border-spacing:0;}'
g[2]='.rttableformat th{padding:5px; font: normal 12px Hiragino Sans GB W3, Helvetica, sans-serif;border:1px  solid #c9e4f5; text-align:center; }'
g[3]='.rttableformat td{padding:5px; font: normal 12px Hiragino Sans GB W3, Helvetica, sans-serif;border:1px  solid #c9e4f5; text-align:center;}'
g[4]='</style>'
g[5]='<tr>'+now+'</tr>'
g[6]='<table class="rttableformat">'
g[7]='<tr><th>合约名</th><th>官方保证金比例</th><th>通天顺保证金比例</th><th>比较结果</th><th>官方涨跌停比例</th><th>通天顺涨跌停比例</th><th>比较结果</th></tr>'
fileHtml = File.new("../tongtianshun/app/views/admin/comparison.html", "w+")
fileHtml.write 'EF BB BF'.split(' ').map{|a|a.hex.chr}.join()                #写文件时解决中文乱码
i=0
  while(i<s) 
    fileHtml.puts g[i]
  i+=1
  end
fileHtml.close() 

