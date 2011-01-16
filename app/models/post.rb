class Post < ActiveRecord::Base
    # Expresses that this class is a Mongoid document
    include Mongoid::Document
    include Mongoid::Timestamps
    
    field :user, :type => String
    field :external_id, :type => String
    field :publish_place_id, :type => String

    field :message
    field :comments, :type => Hash
    field :likes, :type => Hash
    field :published, :type => Boolean

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
    
    @likes_by_user.find.inject(Hash.new(0)) {|h, i| h[i.values[0]] = i.values[1]; h}
  end
  
  def publish_to(place, access_token)
    request_params = {
      :access_token => access_token,
      :message => message 
    }
    response = base_url["#{place}/feed"].post_form(request_params).deserialise
    self.external_id = response['id']      
    self.publish_place_id = place
    self.published = true
  end
  
  
  protected
  
  def base_url
    "https://graph.facebook.com".to_uri
  end  
  
end
