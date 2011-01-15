class Post < ActiveRecord::Base
  # Expresses that this class is a Mongoid document
    include Mongoid::Document
  #include Mongoid::TimeStamps
    #field :user, :type => ObjectId
    field :external_id, :type => String
    # Default type is string
    field :message
    field :comments, :type => Hash
    field :likes, :type => Hash

    def self.by_likes(user)
      map <<-eos 
      function() { 
          if(this.likes) {
            for(var like in this.likes) { 
              emit(this.likes[like],1); 
            }
          } 
        }
      eos
      
      reduce <<-eos 
          function(k, vals) { 
            var sum = 0; 
            for(var i in vals) {
              sum += vals[i];
            }
            return sum;
          }
        eos
        
    @likes_by_user  = Post.collection.map_reduce(map, 
      reduce, { :query => { :user => user }, 
      :out => "Post.by_likes(#{user})"})
    
    @likes_by_user.find.inject(Hash.new(0)) {|h, i| h[i.values[0].to_date] = i.values[1]; h}
  end
end
