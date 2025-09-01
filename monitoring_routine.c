#include "philosophers.h"

static int	check_death(t_data *data, int i, long current_time)
{
	if (current_time - data->philos[i].last_meal > data->time_to_die)
	{
		pthread_mutex_lock(&data->death_lock);
		printf("%ld %d died\n", current_time - data->start_time,
			data->philos[i].id);
		data->someone_died = 1;
		pthread_mutex_unlock(&data->death_lock);
		return (1);
	}
	return (0);
}

static int	check_meals(t_data *data, int *all_ate_enough)
{
	int	i;

	i = 0;
	while (i < data->nb_philos)
	{
		if (data->is_limited_meals
			&& data->philos[i].nb_eaten < data->nb_must_eat)
			*all_ate_enough = 0;
		i++;
	}
	if (data->is_limited_meals && *all_ate_enough == 1)
	{
		pthread_mutex_lock(&data->death_lock);
		data->someone_died = 1;
		pthread_mutex_unlock(&data->death_lock);
		return (1);
	}
	return (0);
}

void	*monitor_routine(void *arg)
{
	t_data	*data;
	int		i;
	long	current_time;
	int		all_ate_enough;

	data = (t_data *)arg;
	while (!data->someone_died)
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
