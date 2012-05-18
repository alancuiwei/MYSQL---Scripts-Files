# -*- encoding : utf-8 -*-

#if RUBY_VERSION =~ /1.9/

# Encoding.default_external = Encoding::UTF_8

# Encoding.default_internal = Encoding::UTF_8

#end
require 'date'
require 'rubygems'
require 'watir-webdriver' 
require "open-uri"
require 'mysql' 
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


#大连
the_first.upto(the_last){|x|
date=x.to_s[0,4]+x.to_s[5,2]+x.to_s[8,2]
begin
browser =Watir::Browser.new:ff
browser.goto'http://www.dce.com.cn/PublicWeb/MainServlet?action=Pu00011_search' 
browser.text_field(:name, "Pu00011_Input.trade_date").set(date)
browser.button(:name, "Submit").click
    browser.window(:title=>"大连商品交易所 日行情表").use do  
      file = File.new("dalian.txt", "w+")	 
      file.puts browser.html()	
      file.close()
    end  
browser.close
rescue
browser.close
puts date+',dalian false'
next
end 
f=open('dalian.txt')                   
g=f.readlines
s=g.length

i=0	   
while(i<s)                          #删除空行
    g[i]=g[i].force_encoding('utf-8')
    if(not g[i]=~(/\w+/))
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
    if(g[i].include?('nowrap'))
        j=i
	    break
    end	
    i += 1 
end
while(i<s)                        
    if(g[i].include?('table'))
        k=i
	    break
    end	
    i += 1 
end
i=j
begin
s=k+1
puts date+',dalian true'
rescue
next
end
while(i<s)
   g[i]=g[i].encode('utf-8')
   g[i]=g[i].gsub(/豆一/,'a')
   g[i]=g[i].gsub(/豆二/,'b')
   g[i]=g[i].gsub(/玉米/,'c')
   g[i]=g[i].gsub(/焦炭/,'j')
   g[i]=g[i].gsub(/聚乙烯/,'l')
   g[i]=g[i].gsub(/豆粕/,'m')
   g[i]=g[i].gsub(/棕榈油/,'p')
   g[i]=g[i].gsub(/聚氯乙烯/,'v')
   g[i]=g[i].gsub(/豆油/,'y')
   g[i]=g[i].gsub(/大豆/,'s')  
   g[i]=g[i].gsub(/小计/,'subtotal')
   g[i]=g[i].gsub(/总计/,'grandtotal')
   g[i]=g[i].gsub(/<\/td>/,'')
   g[i]=g[i].gsub(/<\/tr>/,'')
   g[i]=g[i].gsub(/<(.+)>/,'')
  i+=1
end
i=j
while(i<s)
   g[i]=g[i].gsub(/ /,'')
   g[i]=g[i].gsub(/,/,'')
   g[i]=g[i].gsub(/;/,'')
   if(g[i].gsub(/\n/,'')=='-')
   g[i]=0
   end
  i+=1
end

i=j	
file = File.new("dalian2.txt", "w+")
while(i<s) 
    file.puts g[i]
    i+=1
end
file.close() 

f=open('dalian2.txt')            
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                          #删除空行
    line_array[i]=line_array[i].force_encoding('utf-8')
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
    line_array[i]=line_array[i].force_encoding('utf-8')          
    if(line_array[i]=~(/[a-zA-Z]+/))
	   j+=1
	   g[j-1]=line_array[i].gsub(/\W/,'')	    
	end
    if (line_array[i]=~(/-{0,1}\d+.{0,1}\d*/))
	    g[j-1]=g[j-1].to_s.gsub(/\n/,'')+','+line_array[i].to_s
    end	
    i += 1 
end
s=j
f=Array.new(s,0)
i=0
k=0
while(i<s)
    if(g[i][1]=~(/,/))
     f[k]=g[i].gsub(/ /,'')
	 k+=1
	 end
i+=1
end
s=k
i=0
while(i<s)
     dat=date[0,4]+'-'+date[4,2]+'-'+date[6,2]
    f[i]=f[i].split(",")[0]+f[i].split(",")[1].to_s+','+dat+','+f[i].split(",")[2].to_s+','+
	f[i].split(",")[3].to_s+','+f[i].split(",")[4].to_s+','+f[i].split(",")[5].to_s+','+
	f[i].split(",")[10].to_s+','+f[i].split(",")[11].to_s+','+f[i].split(",")[7].to_s+',0,'+f[i].split(",")[0]+',0'	
  i+=1
end
i=0	
file = File.new("dalian3.txt", "w+")
while(i<s) 
    file.puts f[i]
    i+=1
end
file.close() 
puts s
begin
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("delete from marketdaydata_t")
i=0
while(i<s) 
        a=f[i].split(',')
        t="insert into marketdaydata_t values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
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





#郑州

the_first.upto(the_last){|x|
date=x.to_s[0,4]+x.to_s[5,2]+x.to_s[8,2]
a='http://www.czce.com.cn/portal/exchange/'+date[0,4]+'/datadaily/'+date.gsub(/\n/,'')+'.txt'

begin
file=open(a){|x|
aFile = File.new("zhengzhou.txt","w")
while line = x.gets                          
         aFile.puts line
 end 
 aFile.close 
}  
puts date+',zhengzhou true'
rescue
puts date+',zhengzhou false'
next
end 

go=open('zhengzhou.txt')              
g=go.readlines           
s= g.length
i=0
j=0
go=Array.new(s,0)
while(i<s)
    g[i]=g[i].to_s
    if(g[i][0,5]=~/[a-zA-Z]{1,2}\d{1,4}/)
	dat=date[0,4]+'-'+date[4,2]+'-'+date[6,2]
    go[j]=g[i].split(",")[0]+','+dat+','+g[i].split(",")[2].to_s+','+
	g[i].split(",")[3].to_s+','+g[i].split(",")[4].to_s+','+g[i].split(",")[5].to_s+','+
	g[i].split(",")[9].to_s+','+g[i].split(",")[10].to_s+','+g[i].split(",")[6].to_s+',0,'+g[i].split(",")[0][0,2]+',0'
	j+=1
	end
	i+=1
end
s=j
puts s
begin
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("delete from marketdaydata_t")
i=0
while(i<s) 
        a=go[i].split(',')
        t="insert into marketdaydata_t values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
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

#上海
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
    if(line_array[i].include?('bgcolorB'))
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
   line_array[i]=line_array[i].gsub(/铝/,'al')
   line_array[i]=line_array[i].gsub(/锌/,'zn')
   line_array[i]=line_array[i].gsub(/铜/,'cu')
   line_array[i]=line_array[i].gsub(/铅/,'pb')
   line_array[i]=line_array[i].gsub(/黄金/,'au')
   line_array[i]=line_array[i].gsub(/天然橡胶/,'ru')
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
#dbh.query("delete from marketdaydata_t")
i=0
while(i<s) 
        a=g[i].split(',')
        t="insert into marketdaydata_t values('"+a[0]+"','"+a[1]+"',"+a[2]+","+a[3]+","+a[4]+","+a[5]+","+a[6]+","+a[7]+","+a[8]+","+a[9]+",'"+a[10]+"',"+a[11]+");"
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


