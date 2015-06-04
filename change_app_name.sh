# change this to your app's class name and uncomment it - for example:
NEWNAME=TollMaster
NEWUNDERSCOREDNAME=tollmaster

sed "s/TodoList/$NEWNAME/g" config/application.rb > _tmp; mv _tmp config/application.rb

sed "s/TodoList/$NEWNAME/g" config/environment.rb > _tmp; mv _tmp config/environment.rb 
sed "s/TodoList/$NEWNAME/g" config/environments/development.rb > _tmp; mv _tmp config/environments/development.rb 
sed "s/TodoList/$NEWNAME/g" config/environments/production.rb > _tmp; mv _tmp config/environments/production.rb 
sed "s/TodoList/$NEWNAME/g" config/environments/test.rb > _tmp; mv _tmp config/environments/test.rb 
sed "s/TodoList/$NEWNAME/g" config/initializers/secret_token.rb > _tmp; mv _tmp config/initializers/secret_token.rb 
sed "s/TodoList/$NEWNAME/g" config/initializers/secret_token.rb > _tmp; mv _tmp config/initializers/secret_token.rb 
sed "s/TodoList/$NEWNAME/g" config/initializers/secret_token.rb > _tmp; mv _tmp config/initializers/secret_token.rb 
sed "s/TodoList/$NEWNAME/g" config/initializers/session_store.rb > _tmp; mv _tmp config/initializers/session_store.rb 
sed "s/TodoList/$NEWNAME/g" config/routes.rb > _tmp; mv _tmp config/routes.rb 
sed "s/TodoList/$NEWNAME/g" Rakefile > _tmp; mv _tmp Rakefile 
sed "s/_todo_list/_$NEWUNDERSCOREDNAME/g" config/initializers/session_store.rb > _tmp; mv _tmp config/initializers/session_store.rb

sed "s/todo_list/$NEWUNDERSCOREDNAME/g" config/deploy.rb > _tmp; mv _tmp config/deploy.rb
