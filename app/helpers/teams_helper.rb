module TeamsHelper
	def assign_players(players,total,sport,user_stat)
		teams = limit_players(players,total,user_stat)
		locations = location_results(teams,sport)
		teams = Team.shuffle_rand_teams(teams,total)
		match = Match.create_match(sport.id,locations[0])
		if match.save
			home = Team.create_teams("true",sport.id,match.id)
			away = Team.create_teams("false",sport.id,match.id)
			if home.save && away.save
				result = Userteam.join_team(teams[:Home],home,sport.id)
				return result if result!= "success"
				result = Userteam.join_team(teams[:Away],away,sport.id)
				return result if result!= "success"
				{Home:home,Home_team: parse_team_inform(teams[:Home]),Away:away,Away_team:parse_team_inform(teams[:Away]),match:match}
			else
				return home.errors.full_messages if home.errors.full_messages != nil
				return away.errors.full_messages if away.errors.full_messages != nil
			end
		else
			match.errors.full_messages
		end
	end

	def limit_players(players,total,user_stat)
		players = players.order(:updated_at)
		i = 1
		teams = [user_stat]
		while i < total
			player = User.find(players[i].user_id)
			teams << player
			i+=1
		end
		teams
	end

	def parse_team_inform(teams)
		teams.map! do |user|
			pass_user_params(user)
		end
		teams
	end
end
