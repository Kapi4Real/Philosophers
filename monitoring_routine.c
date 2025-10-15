#include "philosophers.h"

static int	check_death(t_data *data, int i, long current_time)
{
	int	died;

	died = 0;
	pthread_mutex_lock(&data->meal_lock);
	if (current_time - data->philos[i].last_meal > data->time_to_die)
	{
		pthread_mutex_unlock(&data->meal_lock);
		pthread_mutex_lock(&data->death_lock);
		if (!data->someone_died)
		{
			printf("%ld %d died\n", current_time - data->start_time,
				data->philos[i].id);
			data->someone_died = 1;
			died = 1;
		}
		pthread_mutex_unlock(&data->death_lock);
		return (died);
	}
	pthread_mutex_unlock(&data->meal_lock);
	return (0);
}

static int	check_meals(t_data *data, int *all_ate_enough)
{
	int	i;

	i = 0;
	*all_ate_enough = 1;
	pthread_mutex_lock(&data->meal_lock);
	while (i < data->nb_philos)
	{
		if (data->is_limited_meals
			&& data->philos[i].nb_eaten < data->nb_must_eat)
		{
			*all_ate_enough = 0;
			break ;
		}
		i++;
	}
	pthread_mutex_unlock(&data->meal_lock);
	if (data->is_limited_meals && *all_ate_enough == 1)
	{
		pthread_mutex_lock(&data->death_lock);
		data->someone_died = 1;
		pthread_mutex_unlock(&data->death_lock);
		return (1);
	}
	return (0);
}

static int	should_stop_monitor(t_data *data)
{
	int	stop;

	pthread_mutex_lock(&data->death_lock);
	stop = data->someone_died;
	pthread_mutex_unlock(&data->death_lock);
	return (stop);
}

void	*monitor_routine(void *arg)
{
	t_data	*data;
	int		i;
	long	current_time;
	int		all_ate_enough;

	data = (t_data *)arg;
	while (!should_stop_monitor(data))
	{
		i = 0;
		all_ate_enough = 1;
		while (i < data->nb_philos)
		{
			current_time = get_time();
			if (check_death(data, i, current_time))
				return (NULL);
			i++;
		}
		if (check_meals(data, &all_ate_enough))
			return (NULL);
		usleep(1000);
	}
	return (NULL);
}
