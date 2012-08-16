#encoding: utf-8
require "open-uri"
require 'date'

now_time=Time.new
a=now_time.min.to_s
b=(a[-1,1].to_i/2+1).to_s
puts g='Stocks/file'+b+'.txt'
h=open(g)                
line_array=h.readlines
ss=line_array.length
j=0	   
while(j<ss)                       
   begin
   if(g=line_array[j].split('.')[1].gsub(/\n/,'').chomp=='ss')
   g='sh'+line_array[j].split('.')[0].chomp
   #g='ss600000'
   else
   g='sz'+line_array[j].split('.')[0].chomp
  end
  gg='Stocks/'+line_array[j].gsub(/\n/,'').chomp+'.csv'
  puts source='http://hq.sinajs.cn/list='+g.chomp

   logfile=open(gg,'a')
   open(source){|x|
     while line = x.gets                      
       logfile.puts line.split(',')[30]+','+line.split(',')[1]+','+line.split(',')[4]+','+line.split(',')[5]+','+line.split(',')[3]+','+line.split(',')[8] 
	 #  logfile.puts line.split(',')[0].split('"')[1]+','+line_array[j].gsub(/\n/,'')+','+line.split(',')[30]+','+line.split(',')[1]+','+line.split(',')[4]+','+line.split(',')[5]+','+line.split(',')[3]+','+line.split(',')[8] 
     end 
   }     
   logfile.close
   rescue
   j=j+1
   next
   end
   j=j+1
end



=begin
#encoding: utf-8
require "open-uri"

h=open('Stocks/file.txt')                
line_array=h.readlines
ss=line_array.length
j=0	   
while(j<ss)                       
   begin
   if(g=line_array[j].split('.')[1].gsub(/\n/,'').chomp=='ss')
   g='sh'+line_array[j].split('.')[0].chomp
   #g='ss600000'
   else
   g='sz'+line_array[j].split('.')[0].chomp
  end
  gg='Stocks/'+line_array[j].gsub(/\n/,'').chomp+'.csv'
  puts source='http://hq.sinajs.cn/list='+g.chomp

   logfile=open(gg,'a')
   open(source){|x|
     while line = x.gets                      
       logfile.puts line.split(',')[30]+','+line.split(',')[1]+','+line.split(',')[4]+','+line.split(',')[5]+','+line.split(',')[3]+','+line.split(',')[8] 
	 #  logfile.puts line.split(',')[0].split('"')[1]+','+line_array[j].gsub(/\n/,'')+','+line.split(',')[30]+','+line.split(',')[1]+','+line.split(',')[4]+','+line.split(',')[5]+','+line.split(',')[3]+','+line.split(',')[8] 
     end 
   }     
   logfile.close
   rescue
   j=j+1
   next
   end
   j=j+1
end
=end

=begin
#encoding: utf-8
require "open-uri"
g='sz184706'
gg='Stocks/184706.sz.csv'
source='http://hq.sinajs.cn/list='+g.chomp
logfile=open(gg,'a')
open(source){|x|
  while line = x.gets                      
  logfile.puts line.split(',')[30]+','+line.split(',')[1]+','+line.split(',')[4]+','+line.split(',')[5]+','+line.split(',')[3]+','+line.split(',')[8] 
  #  logfile.puts line.split(',')[0].split('"')[1]+','+line_array[j].gsub(/\n/,'')+','+line.split(',')[30]+','+line.split(',')[1]+','+line.split(',')[4]+','+line.split(',')[5]+','+line.split(',')[3]+','+line.split(',')[8] 
   end 
  }     
logfile.close
=end
#  http://download.finance.yahoo.com/d/quotes.csv?s=600000.ss&f=sd1ohgp3v     

#http://hq.sinajs.cn/list=sh600000

=begin
#encoding: utf-8
require "open-uri"

h=open('Stocks/file.txt')                
line_array=h.readlines
ss=line_array.length
j=0	   
while(j<ss)                       
   puts g=line_array[j].gsub(/\n/,'')
   file='Stocks/'+g.chomp+'.csv'
   aFile = File.new(file,"w") 
    aFile.puts 'Date,Open,High,Low,Close,Volume'
   aFile.close 
   j=j+1
end
=end