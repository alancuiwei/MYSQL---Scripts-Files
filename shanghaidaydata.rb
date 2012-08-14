#encoding: utf-8
require 'rubygems'                   #  windows
require "open-uri"
require 'mysql'
require 'watir'  
require 'date'  
require "iconv"  
=begin
收集上海2011年12月之前的期货数据
=end  

class String  
  def to_gbk   
    Iconv.iconv("GBK//IGNORE", "UTF-8//IGNORE", self).to_s   
  end  
  
  def to_utf8   
    #p "my own string"   
    Iconv.iconv("UTF-8//IGNORE", "GBK//IGNORE", self).to_s   
  end  
  
  def to_utf8_valid   
  
    if !self.valid_encoding?   
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')   
      return ic.iconv(self)   
    end  
    self  
  end  
  
end  
def fact(n) 
end 
print fact(ARGV)              #20110418
date=ARGV[0].to_s
date2=ARGV[1].to_s
a=date[0,4].to_i
b=date[4,2].to_i
c=date[6,2].to_i
d=date2[0,4].to_i
e=date2[4,2].to_i
f=date2[6,2].to_i
the_first=Date.new(a,b,c)
the_last=Date.new(d,e,f)
=begin
#上海  近期
the_first.upto(the_last){|x|
date=x.to_s[0,4]+x.to_s[5,2]+x.to_s[8,2]
a='http://www.shfe.com.cn/dailydata/kx/kx'+date.gsub(/\n/,'')+'.html'
begin
file=open(a){|x|
aFile = File.new("shanghai.txt","w")
while line = x.gets                          
         aFile.puts line.encode('utf-8')     
 end 
 aFile.close 
}  
rescue
next
end 
f=open('shanghai.txt')              #读网页源码，进行处理
line_array=f.readlines
s=line_array.length

i=0	   
while(i<s)                          #删除空行
    if(! line_array[i]=~(/\w+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	   
while(i<s)                        
    if(line_array[i].include?('bgcolorB'))  #<tr align="right">
        j=i
	    break
    end	
    i += 1 
end

while(i<s)                        
    if(line_array[i].include?('table'))
       k=i

	    break
    end	
    i += 1 
end
i=j
while(i<k)
   line_array[i]=line_array[i].force_encoding('utf-8')
   line_array[i]=line_array[i].gsub(/right'></,"right'>0<")
   line_array[i]=line_array[i].gsub(/白银/,'ag')
   line_array[i]=line_array[i].gsub(/铝/,'al')
   line_array[i]=line_array[i].gsub(/锌/,'zn')
   line_array[i]=line_array[i].gsub(/铜/,'cu')
   line_array[i]=line_array[i].gsub(/铅/,'pb')
   line_array[i]=line_array[i].gsub(/黄金/,'au')
   line_array[i]=line_array[i].gsub(/天然橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/燃料油/,'fu')
   line_array[i]=line_array[i].gsub(/螺纹钢/,'rb')
   line_array[i]=line_array[i].gsub(/线材/,'wr')
   line_array[i]=line_array[i].gsub(/小计/,'subtotal')
   line_array[i]=line_array[i].gsub(/总计/,'grandtotal')
   if(line_array[i]=~/.*>[a-zA-Z]{2}.*/)
    l=i
   end
   if(line_array[i].include?('><'))
   line_array[i]=line_array[l]
   end
   if(line_array[i].include?('grandtotal'))
   k=i
   end
   line_array[i]=line_array[i].gsub(/<\/td>/,'')
   line_array[i]=line_array[i].gsub(/<(.+)>/,'')
   i+=1
end

file = File.new("shanghai2.txt", "w+")
i=j
while(i<k) 
    file.puts line_array[i]
    i+=1
end
file.close() 

f=open('shanghai2.txt')            
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                          #删除空行
    if(not line_array[i]=~(/[a-zA-Z\d]+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
i=0	
j=0
g=Array.new(s,0)   
while(i<s)                         
    if(line_array[i]=~(/[a-zA-Z]+/))
	   j+=1
	   g[j-1]=line_array[i].gsub(/\W/,'')	    
	end
    if (line_array[i]=~(/\d+/))
	    g[j-1]=g[j-1].gsub(/\n/,'')+','+line_array[i].gsub(/\D/,'')
    end	
    i += 1 
end
s=j
i=0	   
while(i<s)                         
    if(g[i].split(",")[0]=='subtotal')
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
s=s-2
i=0	   
while(i<s)                         
    if(not g[i].include?(","))
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
i=0	   
while(i<s)                         
	dat=date[0,4]+'-'+date[4,2]+'-'+date[6,2]
	g[i]=g[i].split(",")[0]+g[i].split(",")[1]+','+dat+','+g[i].split(",")[3].to_s+','+
	g[i].split(",")[4].to_s+','+g[i].split(",")[5].to_s+','+g[i].split(",")[6].to_s+','+
	g[i].split(",")[10].to_s+','+g[i].split(",")[11].to_s+','+g[i].split(",")[7].to_s+',0,'+g[i].split(",")[0]+',0'
    i += 1 
end
if(s!=0)
puts date+',shanghai true'
else
puts date+',shanghai false'
end
puts s
begin
dbh = Mysql.init
dbh.options(Mysql::SET_CHARSET_NAME, 'utf8')
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("delete from table3")
i=0
while(i<s) 
        a=g[i].split(',')
        t="insert into table3 values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
       # puts t
        dbh.query(t)  
      i += 1 
end 

rescue Mysql::Error=>e           #Mysql执行错误时给出错误类型
puts "Error code:#{e.errno}"
puts "Error message:#{e.error}"
puts "Error SQLSTATE:#{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
dbh.close if dbh
end
}
=end

=begin
#上海         20000101~20030821 20040329 20040517~20040518 20040609 20040719 20040726 20041203~20041217 20050104~20050113 20050117~2006225
the_first.upto(the_last){|x|
date=x.to_s[0,4]+x.to_s[5,2]+x.to_s[8,2]
a='http://www.shfe.com.cn/dailydata/kx/kx'+date.gsub(/\n/,'')+'.html'
begin
file=open(a){|x|
aFile = File.new("shanghai.txt","w")
while line = x.gets                          
         aFile.puts line.encode('utf-8')     
 end 
 aFile.close 
}  
rescue
next
end 
f=open('shanghai.txt')              #读网页源码，进行处理
line_array=f.readlines
s=line_array.length

i=0	   
while(i<s)                          #删除空行
    if(! line_array[i]=~(/\w+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	   
while(i<s)                        
    if(line_array[i].include?('<tr align="right">'))
        j=i
	    break
    end	
    i += 1 
end

while(i<s)                        
    if(line_array[i].include?('table'))
      k=i
	    break
    end	
    i += 1 
end

i=j  
while(i<k)    
    g=line_array[i].to_utf8_valid.split('<td>')
    if(g.length>2)    
    g=line_array[i].to_utf8_valid.split(' ')
    a=g.length
	b=k	
	k=k+a-1
	while(b>=i+1)
	c=b+a-1
	line_array[c]=line_array[b]
	b=b-1
	end	
	b=0
	while(b<a)
	line_array[i+b]=g[b]
	b=b+1
	end
    end
    i += 1 
end


i=j
while(i<k)
   line_array[i]=line_array[i].force_encoding('utf-8')
   line_array[i]=line_array[i].gsub(/<td>&nbsp;<\/td>/,"<td>0<\/td>")
   line_array[i]=line_array[i].gsub(/白银/,'ag')
   line_array[i]=line_array[i].gsub(/铝/,'al')
   line_array[i]=line_array[i].gsub(/锌/,'zn')
   line_array[i]=line_array[i].gsub(/铜/,'cu')
   line_array[i]=line_array[i].gsub(/铅/,'pb')
   line_array[i]=line_array[i].gsub(/黄金/,'au')
   line_array[i]=line_array[i].gsub(/天然橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/燃料油/,'fu')
   line_array[i]=line_array[i].gsub(/燃油/,'fu')
   line_array[i]=line_array[i].gsub(/螺纹钢/,'rb')
   line_array[i]=line_array[i].gsub(/线材/,'wr')
   line_array[i]=line_array[i].gsub(/小计/,'subtotal')
   line_array[i]=line_array[i].gsub(/总计/,'grandtotal')
   if(line_array[i]=~/.*>[a-zA-Z]{2}.*/)
    l=i
   end
   if(line_array[i].include?('<td>&nbsp;'))
   line_array[i]='0'
   end
   if(line_array[i].include?('>&nbsp;<'))
   line_array[i]=line_array[l]
   end
   if(line_array[i].include?('grandtotal'))
   k=i
   end
   line_array[i]=line_array[i].gsub(/&nbsp;/,'')
   line_array[i]=line_array[i].gsub(/<\/td>/,'')
   line_array[i]=line_array[i].gsub(/<(.+)>/,'')
   i+=1
end

file = File.new("shanghai2.txt", "w+")
i=j
while(i<k) 
    file.puts line_array[i]
    i+=1
end
file.close() 

f=open('shanghai2.txt')            
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                          #删除空行
    if(not line_array[i]=~(/[a-zA-Z\d]+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	
j=0
g=Array.new(s,0)   
while(i<s)                         
    if(line_array[i]=~(/[a-zA-Z]+/))
	   j+=1
	   g[j-1]=line_array[i].gsub(/\W/,'')	    
	end
    if (line_array[i]=~(/\d+/))
	   g[j-1]=g[j-1].gsub(/\n/,'')+','+line_array[i].gsub(/\D/,'')
    end	
    i += 1 
end
s=j

i=0	   
while(i<s)                         
    if(not (g[i].count ",").to_i==12)
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
s=s-1
i=0	   
while(i<s)                         
    if(not g[i].include?(","))
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	   
while(i<s)                         
	dat=date[0,4]+'-'+date[4,2]+'-'+date[6,2]
	g[i]=g[i].split(",")[0]+g[i].split(",")[1]+','+dat+','+g[i].split(",")[3].to_s+','+
	g[i].split(",")[4].to_s+','+g[i].split(",")[5].to_s+','+g[i].split(",")[6].to_s+','+
	g[i].split(",")[10].to_s+','+g[i].split(",")[11].to_s+','+g[i].split(",")[7].to_s+',0,'+g[i].split(",")[0]+',0'
    i += 1 
end

if(s!=0)
puts date+',shanghai true'
else
puts date+',shanghai false'
end
puts s
begin
dbh = Mysql.init
dbh.options(Mysql::SET_CHARSET_NAME, 'utf8')
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("delete from table3")
i=0
while(i<s) 
        a=g[i].split(',')
        t="insert into table3 values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
       # puts t
        dbh.query(t)  
      i += 1 
end 

rescue Mysql::Error=>e           #Mysql执行错误时给出错误类型
puts "Error code:#{e.errno}"
puts "Error message:#{e.error}"
puts "Error SQLSTATE:#{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
dbh.close if dbh
end
}
=end



=begin
#上海  20030822~20040328  20040430~20040515 20040519~20040608 20040610~20040718 20040720~20040725 20040727~20041202
the_first.upto(the_last){|x|
date=x.to_s[0,4]+x.to_s[5,2]+x.to_s[8,2]
a='http://www.shfe.com.cn/dailydata/kx/kx'+date.gsub(/\n/,'')+'.html'
begin
file=open(a){|x|
aFile = File.new("shanghai.txt","w")
while line = x.gets                          
         aFile.puts line.encode('utf-8')     
 end 
 aFile.close 
}  
rescue
next
end 
f=open('shanghai.txt')             
line_array=f.readlines
s=line_array.length
line=line_array[0].to_utf8_valid.split('</td>')
s=line.length

i=0
aFile = File.new("shanghai1.txt","w")
while(i<s)                     
        aFile.puts line[i].encode('utf-8')     
		i+=1
 end 
aFile.close 
f=open('shanghai1.txt')              
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                        
    if(line_array[i].include?('<td align="center">'))
     puts   j=i
	    break
    end	
    i += 1 
end

while(i<s)                        
    if(line_array[i].include?('table'))
    puts     k=i
	    break
    end	
    i += 1 
end

i=j
while(i<k)
   line_array[i]=line_array[i].force_encoding('utf-8')
   line_array[i]=line_array[i].gsub(/right'></,"right'>0<")
   line_array[i]=line_array[i].gsub(/白银/,'ag')
   line_array[i]=line_array[i].gsub(/铝/,'al')
   line_array[i]=line_array[i].gsub(/锌/,'zn')
   line_array[i]=line_array[i].gsub(/铜/,'cu')
   line_array[i]=line_array[i].gsub(/铅/,'pb')
   line_array[i]=line_array[i].gsub(/黄金/,'au')
   line_array[i]=line_array[i].gsub(/天然橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/燃料油/,'fu')
   line_array[i]=line_array[i].gsub(/燃油/,'fu')
   line_array[i]=line_array[i].gsub(/螺纹钢/,'rb')
   line_array[i]=line_array[i].gsub(/线材/,'wr')
   line_array[i]=line_array[i].gsub(/小计/,'subtotal')
   line_array[i]=line_array[i].gsub(/总计/,'grandtotal')
   if(line_array[i]=~/.*>[a-zA-Z]{2}.*/)
   l=i
   end
   if(line_array[i].include?('<td>&nbsp;'))
   line_array[i]='0'
   end
   if(line_array[i].include?('&nbsp;'))
   line_array[i]=line_array[l]
   end
   if(line_array[i].include?('grandtotal'))
   k=i
   end
   line_array[i]=line_array[i].gsub(/<\/td>/,'')
   line_array[i]=line_array[i].gsub(/<(.+)>/,'')
   i+=1
end

file = File.new("shanghai2.txt", "w+")
i=j
while(i<k) 
    file.puts line_array[i]
    i+=1
end
file.close() 

f=open('shanghai2.txt')            
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                          #删除空行
    if(not line_array[i]=~(/[a-zA-Z\d]+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
i=0	
j=0
g=Array.new(s,0)   
while(i<s)                         
    if(line_array[i]=~(/[a-zA-Z]+/))
	   j+=1
	   g[j-1]=line_array[i].gsub(/\W/,'')	    
	end
    if (line_array[i]=~(/\d+/))
	    g[j-1]=g[j-1].gsub(/\n/,'')+','+line_array[i].gsub(/\D/,'')
    end	
    i += 1 
end
s=j
i=0	   
while(i<s)                         
    if(not (g[i].count ",").to_i==12)
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
s=s-1
i=0	   
while(i<s)                         
    if(not g[i].include?(","))
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
i=0	   
while(i<s)                         
	dat=date[0,4]+'-'+date[4,2]+'-'+date[6,2]
	g[i]=g[i].split(",")[0]+g[i].split(",")[1]+','+dat+','+g[i].split(",")[3].to_s+','+
	g[i].split(",")[4].to_s+','+g[i].split(",")[5].to_s+','+g[i].split(",")[6].to_s+','+
	g[i].split(",")[10].to_s+','+g[i].split(",")[11].to_s+','+g[i].split(",")[7].to_s+',0,'+g[i].split(",")[0]+',0'
    i += 1 
end
if(s!=0)
puts date+',shanghai true'
else
puts date+',shanghai false'
end
puts s

begin
dbh = Mysql.init
dbh.options(Mysql::SET_CHARSET_NAME, 'utf8')
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("delete from table3")
i=0
while(i<s) 
        a=g[i].split(',')
        t="insert into table3 values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
       # puts t
        dbh.query(t)  
      i += 1 
end 

rescue Mysql::Error=>e           #Mysql执行错误时给出错误类型
puts "Error code:#{e.errno}"
puts "Error message:#{e.error}"
puts "Error SQLSTATE:#{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
dbh.close if dbh
end
=end



#上海  20041220~20050103 20061226~20061227
the_first.upto(the_last){|x|
date=x.to_s[0,4]+x.to_s[5,2]+x.to_s[8,2]
a='http://www.shfe.com.cn/dailydata/kx/kx'+date.gsub(/\n/,'')+'.html'
begin
file=open(a){|x|
aFile = File.new("shanghai.txt","w")
while line = x.gets                          
         aFile.puts line.encode('utf-8')     
 end 
 aFile.close 
}  
rescue
next
end 
f=open('shanghai.txt')              #读网页源码，进行处理
line_array=f.readlines
s=line_array.length

i=0	   
while(i<s)                          #删除空行
    if(! line_array[i]=~(/\w+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	   
while(i<s)                        
    if(line_array[i].include?('bgcolorB'))  #<tr align="right">
        j=i
	    break
    end	
    i += 1 
end

while(i<s)                        
    if(line_array[i].include?('table'))
        k=i

	    break
    end	
    i += 1 
end
i=j
while(i<k)
   line_array[i]=line_array[i].force_encoding('utf-8')
   line_array[i]=line_array[i].gsub(/right'></,"right'>0<")
   line_array[i]=line_array[i].gsub(/白银/,'ag')
   line_array[i]=line_array[i].gsub(/铝/,'al')
   line_array[i]=line_array[i].gsub(/锌/,'zn')
   line_array[i]=line_array[i].gsub(/铜/,'cu')
   line_array[i]=line_array[i].gsub(/铅/,'pb')
   line_array[i]=line_array[i].gsub(/黄金/,'au')
   line_array[i]=line_array[i].gsub(/天然橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/橡胶/,'ru')
   line_array[i]=line_array[i].gsub(/燃料油/,'fu')
   line_array[i]=line_array[i].gsub(/螺纹钢/,'rb')
   line_array[i]=line_array[i].gsub(/线材/,'wr')
   line_array[i]=line_array[i].gsub(/小计/,'subtotal')
   line_array[i]=line_array[i].gsub(/总计/,'grandtotal')
   if(line_array[i]=~/.*>[a-zA-Z]{2}.*/)
    l=i
   end
   if(line_array[i].include?('grandtotal'))
   k=i
   end
   if(line_array[i].include?('right">&nbsp;'))
   line_array[i]='0'
   end
   if(line_array[i].include?('right"><'))
   line_array[i]='0'
   end
   if(line_array[i].include?("center'><"))
   line_array[i]=line_array[l]
   end
   line_array[i]=line_array[i].gsub(/<\/tr>/,'')
   line_array[i]=line_array[i].gsub(/<\/td>/,'')
   line_array[i]=line_array[i].gsub(/<(.+)>/,'')
   i+=1
end

file = File.new("shanghai2.txt", "w+")
i=j
while(i<k) 
    file.puts line_array[i]
    i+=1
end
file.close() 

f=open('shanghai2.txt')            
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                          #删除空行
    if(not line_array[i]=~(/[a-zA-Z\d]+/))
        u=i
        while(u<s)
	        line_array[u]=line_array[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	
j=0
g=Array.new(s,0)   
while(i<s)                         
    if(line_array[i]=~(/[a-zA-Z]+/))
	   j+=1
	   g[j-1]=line_array[i].gsub(/\W/,'')	    
	end
    if (line_array[i]=~(/\d+/))
	    g[j-1]=g[j-1].gsub(/\n/,'')+','+line_array[i].gsub(/\D/,'')
    end	
    i += 1 
end
s=j
i=0	   
while(i<s)                         
    if(g[i].split(",")[0]=='subtotal')
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end

i=0	   
while(i<s)                         
    if(not g[i].include?(","))
        u=i
        while(u<s)
	        g[u]=g[u+1] 
	        u += 1
	    end
        s -= 1
    end	
    i += 1 
end
i=0	   
while(i<s)                         
    puts g[i]
    i += 1 
end
i=0	   
while(i<s)                         
	dat=date[0,4]+'-'+date[4,2]+'-'+date[6,2]
	g[i]=g[i].split(",")[0]+g[i].split(",")[1]+','+dat+','+g[i].split(",")[3].to_s+','+
	g[i].split(",")[4].to_s+','+g[i].split(",")[5].to_s+','+g[i].split(",")[6].to_s+','+
	g[i].split(",")[10].to_s+','+g[i].split(",")[11].to_s+','+g[i].split(",")[7].to_s+',0,'+g[i].split(",")[0]+',0'
    i += 1 
end
if(s!=0)
puts date+',shanghai true'
else
puts date+',shanghai false'
end
puts s
begin
dbh = Mysql.init
dbh.options(Mysql::SET_CHARSET_NAME, 'utf8')
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("delete from table3")
i=0
while(i<s) 
        a=g[i].split(',')
        t="insert into table3 values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
       # puts t
        dbh.query(t)  
      i += 1 
end 

rescue Mysql::Error=>e           #Mysql执行错误时给出错误类型
puts "Error code:#{e.errno}"
puts "Error message:#{e.error}"
puts "Error SQLSTATE:#{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
dbh.close if dbh
end
}
