/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ccouton <marvin@42.fr>                     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/29 00:00:00 by ccouton           #+#    #+#             */
/*   Updated: 2025/06/29 00:00:00 by ccouton          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../philosophers.h"

int	init_mutexes(t_data *data)
{
	int		i;

	i = 0;
	data->forks = malloc(sizeof(pthread_mutex_t) * data->nb_philos);
	if (!data->forks)
		return (0);
	while (i < data->nb_philos)
	{
		if (pthread_mutex_init(&data->forks[i], NULL) != 0)
			return (0);
		i++;
	}
	if (pthread_mutex_init(&data->print_lock, NULL) != 0)
		return (0);
	if (pthread_mutex_init(&data->death_lock, NULL) != 0)
		return (0);
	return (1);
}

int	init_philosophers(t_data *data)
{
	int		i;

	i = 0;
	data->philos = malloc(sizeof(t_philo) * data->nb_philos);
	if (!data->philos)
		return (0);
	while (i < data->nb_philos)
	{
		data->philos[i].id = i + 1;
		data->philos[i].nb_eaten = 0;
		data->philos[i].last_meal = data->start_time;
		data->philos[i].left_fork = &data->forks[i];
		data->philos[i].right_fork = &data->forks[(i + 1) % data->nb_philos];
		data->philos[i].data = data;
		i++;
	}
	return (1);
}

int	init_simulation(t_data *data)
{
	data->start_time = get_time();
	data->someone_died = 0;
	if (!init_mutexes(data))
		return (0);
	if (!init_philosophers(data))
		return (0);
	return (1);
}
