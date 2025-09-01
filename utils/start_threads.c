#include "../philosophers.h"

int	start_threads(t_data *data)
{
	int		i;

	i = 0;
	while (i < data->nb_philos)
	{
		if (pthread_create(&data->philos[i].thread, NULL, philosopher_routine,
				&data->philos[i]) != 0)
			return (0);
		i++;
	}
	if (pthread_create(&data->monitor, NULL, monitor_routine, data) != 0)
		return (0);
	return (1);
}
