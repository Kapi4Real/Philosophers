/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philosophers.h                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ccouton <marvin@42.fr>                     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/29 00:00:00 by ccouton           #+#    #+#             */
/*   Updated: 2025/06/29 00:00:00 by ccouton          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILOSOPHERS_H
# define PHILOSOPHERS_H

# include <pthread.h>
# include <stdlib.h>
# include <unistd.h>
# include <sys/time.h>
# include <stdio.h>

typedef struct s_data	t_data;

typedef struct s_philo
{
	int				id;
	int				nb_eaten;
	long			last_meal;
	pthread_t		thread;
	pthread_mutex_t	*left_fork;
	pthread_mutex_t	*right_fork;
	t_data			*data;
}	t_philo;

typedef struct s_data
{
	int				nb_philos;
	int				time_to_die;
	int				time_to_eat;
	int				time_to_sleep;
	int				nb_must_eat;
	int				is_limited_meals;
	long			start_time;
	pthread_mutex_t	*forks;
	pthread_mutex_t	print_lock;
	pthread_mutex_t	death_lock;
	int				someone_died;
	pthread_t		monitor;
	t_philo			*philos;
}	t_data;

int		is_number(char *str);
long	get_time(void);
int		parse_args(t_data *data, int argc, char **argv);
int		init_mutexes(t_data *data);
int		init_philosophers(t_data *data);
int		init_simulation(t_data *data);
void	print_status(t_philo *philo, char *status);
void	*philosopher_routine(void *arg);
void	*monitor_routine(void *arg);
int		start_threads(t_data *data);
void	precise_usleep(long milliseconds);
void	cleanup(t_data *data);

#endif
