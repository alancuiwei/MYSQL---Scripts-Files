#encoding: utf-8
require "open-uri"
 
#历史股票数据

def fact(n) 
end 
print fact(ARGV)              #20110418
date=ARGV[0].to_s
date2=ARGV[1].to_s
c=date[0,4].to_i
a=date[4,2].to_i
b=date[6,2].to_i
f=date2[0,4].to_i
d=date2[4,2].to_i
e=date2[6,2].to_i
a=a-1
d=d-1 
=begin
h=open('list-2.txt')            
line_array=h.readlines
ss=line_array.length

j=0	   
while(j<ss)                       

   begin
   g=Array.new(2,0)
   g=line_array[j].split(",")
   g[0]=g[0].gsub(/\n/,'')
   puts g[1]=g[1].gsub(/\n/,'')  
   #g='600000.SS'
   i=0 
   s=0

  puts  source='http://table.finance.yahoo.com/table.csv?s='+g[1]+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&ignore=.csv'
   #source='http://ichart.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&g=d&ignore=.csv'
   file='Stocks/'+g[1]+'.csv'
   aFile = File.new(file,"w") 
   open(source){|x|
     while line = x.gets                      
         aFile.puts line     
     end 
         aFile.close 
    }
   rescue
   j=j+1
   next
   end
   j=j+1
end
=end



=begin
   begin
   g='营口港,600318.ss'
   g=g.split(",")
   g[0]=g[0].gsub(/\n/,'')
   puts g[1]=g[1].gsub(/\n/,'')  
   #g='600000.SS'
   i=0 
   s=0

   source='http://table.finance.yahoo.com/table.csv?s='+g[1]+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&ignore=.csv'
   #source='http://ichart.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&g=d&ignore=.csv'
   file='Stocks/'+g[1]+'.csv'
   aFile = File.new(file,"w") 
   open(source){|x|
     while line = x.gets                         
         aFile.puts line     
     end 
         aFile.close 
    }
   rescue
   end
=end



h=open('Stocks/stock/file.txt')            
line_array=h.readlines
ss=line_array.length

j=0	   
while(j<ss)                       
   begin
  puts g=line_array[j].gsub(/\n/,'')
   #g='600000.SS'
   i=0 
   s=0
   source='http://table.finance.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&ignore=.csv'
   source=source.gsub(/\n/,'')
   #source='http://ichart.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&g=d&ignore=.csv'
   file='Stocks/'+g+'.csv'
   aFile = File.new(file,"w") 
   open(source){|x|
     while line = x.gets                      
         aFile.puts line     
     end 
         aFile.close 
    }
   rescue
   j=j+1
   next
   end
   j=j+1
end


=begin
   begin
   g='600320.ss'
   i=0 
   s=0
  source='http://ichart.yahoo.com/table.csv?s='+g
  # puts source='http://table.finance.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&ignore=.csv'
  #source='http://ichart.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+b.to_s+'&c='+c.to_s+'&d='+d.to_s+'&e='+e.to_s+'&f='+f.to_s+'&g=d&ignore=.csv'
   file='Stocks/'+g+'.csv'
   aFile = File.new(file,"w") 
   open(source){|x|
     while line = x.gets                         
         aFile.puts line     
     end 
         aFile.close 
    }
   rescue
   end
=end

