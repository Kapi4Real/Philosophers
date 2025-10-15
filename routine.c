/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ccouton <ccouton@student.42.fr>      +#+  +:+       +#+              */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/15 00:29:04 by ccouton       #+#    #+#                 */
/*   Updated: 2025/10/15 00:29:04 by ccouton      ###   ########.fr           */
/*                                                                            */
/* ************************************************************************** */

#include "philosophers.h"

static void	take_forks(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->death_lock);
	stop = philo->data->someone_died;
	pthread_mutex_unlock(&philo->data->death_lock);
	if (stop)
		return ;
	if (philo->id % 2 == 0)
	{
		pthread_mutex_lock(philo->right_fork);
		print_status(philo, "has taken a fork");
		pthread_mutex_lock(philo->left_fork);
		print_status(philo, "has taken a fork");
	}
	else
	{
		pthread_mutex_lock(philo->left_fork);
		print_status(philo, "has taken a fork");
		pthread_mutex_lock(philo->right_fork);
		print_status(philo, "has taken a fork");
	}
}

static void	eat_and_release(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->death_lock);
	stop = philo->data->someone_died;
	pthread_mutex_unlock(&philo->data->death_lock);
	if (stop)
		return ;
	print_status(philo, "is eating");
	pthread_mutex_lock(&philo->data->meal_lock);
	philo->last_meal = get_time();
	philo->nb_eaten++;
	pthread_mutex_unlock(&philo->data->meal_lock);
	precise_usleep(philo->data->time_to_eat);
	pthread_mutex_unlock(philo->left_fork);
	pthread_mutex_unlock(philo->right_fork);
}

static void	sleep_and_think(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->death_lock);
	stop = philo->data->someone_died;
	pthread_mutex_unlock(&philo->data->death_lock);
	if (stop)
		return ;
	print_status(philo, "is sleeping");
	precise_usleep(philo->data->time_to_sleep);
	pthread_mutex_lock(&philo->data->death_lock);
	stop = philo->data->someone_died;
	pthread_mutex_unlock(&philo->data->death_lock);
	if (stop)
		return ;
	print_status(philo, "is thinking");
}

static int	check_stop(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->death_lock);
	stop = philo->data->someone_died;
	pthread_mutex_unlock(&philo->data->death_lock);
	return (stop);
}

void	*philosopher_routine(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	if (philo->data->nb_philos == 1)
	{
		print_status(philo, "has taken a fork");
		precise_usleep(philo->data->time_to_die);
		return (NULL);
	}
	while (!check_stop(philo))
	{
		take_forks(philo);
		if (check_stop(philo))
		{
			pthread_mutex_unlock(philo->left_fork);
			pthread_mutex_unlock(philo->right_fork);
			break ;
		}
		eat_and_release(philo);
		if (check_stop(philo))
			break ;
		sleep_and_think(philo);
	}
	return (NULL);
}
